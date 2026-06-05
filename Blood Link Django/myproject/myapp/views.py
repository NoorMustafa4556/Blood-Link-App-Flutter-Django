from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout, update_session_auth_hash
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.utils import timezone
from datetime import timedelta
import json

from .models import Profile, BloodRequest, City

# 🚀 LANDING, 🏠 HOME
def landing_view(request):
    if request.user.is_authenticated: return redirect('home')
    return render(request, 'landing.html')

@login_required
def switch_role_view(request):
    current_role = request.session.get('current_role', 'donor' if request.user.profile.is_donor else 'recipient')
    request.session['current_role'] = 'recipient' if current_role == 'donor' else 'donor'
    return redirect('home')

@login_required
def home_view(request):
    if request.user.is_superuser: return redirect('admin_dashboard')
    
    # --- AUTO-CANCEL EXPIRED REQUESTS ---
    now = timezone.now()
    expired_requests = BloodRequest.objects.filter(status='Pending')
    for req in expired_requests:
        if now > req.created_at + timedelta(hours=req.duration):
            req.status = 'Cancelled'
            req.save()

    # --- CHECK DUAL ROLE FROM SESSION ---
    current_role = request.session.get('current_role', 'donor' if request.user.profile.is_donor else 'recipient')
    is_donor = (current_role == 'donor')
    from .models import BloodGroup
    blood_groups = [bg.name for bg in BloodGroup.objects.all()]
    active_requests = BloodRequest.objects.filter(status='Pending').order_by('-created_at')
    
    recent_responses = []
    if is_donor:
        active_requests = active_requests.filter(receiver=request.user)
    else:
        active_requests = active_requests.filter(sender=request.user)
        recent_responses = BloodRequest.objects.filter(sender=request.user, status__in=['Accepted', 'Rejected'], sender_acknowledged=False).order_by('-created_at')[:5]

    show_health_warning = False
    if is_donor and request.user.profile.available:
        latest_completed = BloodRequest.objects.filter(
            receiver=request.user,
            status='Completed'
        ).order_by('-id').first()
        
        if latest_completed:
            cleared_id = request.session.get('cleared_request_id', -1)
            if cleared_id != latest_completed.id:
                show_health_warning = True
        
    return render(request, 'home.html', {
        'active_requests': active_requests, 
        'recent_responses': recent_responses,
        'blood_groups': blood_groups, 
        'is_donor': is_donor,
        'current_role': current_role,
        'show_health_warning': show_health_warning,
    })

@login_required
def search_donors_view(request):
    current_role = request.session.get('current_role')
    if current_role == 'donor': return redirect('home')
    
    blood_group = request.GET.get('blood_group')
    if blood_group:
        blood_group = blood_group.replace(' ', '+')
    city_name = request.GET.get('city')
    donors = Profile.objects.filter(is_donor=True, available=True)
    if blood_group: donors = donors.filter(blood_group=blood_group)
    if city_name: donors = donors.filter(city=city_name)
    cities = City.objects.all()
    from .models import BloodGroup
    blood_groups = [bg.name for bg in BloodGroup.objects.all()]
    pending_donor_ids = list(BloodRequest.objects.filter(sender=request.user, status='Pending').values_list('receiver_id', flat=True))
    return render(request, 'search_results.html', {
        'donors': donors, 
        'blood_group': blood_group, 
        'city': city_name, 
        'cities': cities,
        'blood_groups': blood_groups,
        'pending_donor_ids': pending_donor_ids
    })

@login_required
def donor_profile_view(request, donor_id):
    donor_user = get_object_or_404(User, id=donor_id)
    return render(request, 'donor_profile.html', {'donor': donor_user})

@login_required
def send_blood_request_view(request, donor_id):
    receiver = get_object_or_404(User, id=donor_id)
    
    # --- REQUEST LIMIT (10 MAX) ---
    pending_count = BloodRequest.objects.filter(sender=request.user, status='Pending').count()
    if pending_count >= 10:
        messages.error(request, "You have reached the maximum limit of 10 pending requests.")
        return redirect('history')

    if request.method == "POST":
        existing = BloodRequest.objects.filter(sender=request.user, receiver=receiver, status='Pending').exists()
        if existing:
            messages.error(request, "A pending request already exists for this donor.")
            return redirect('donor_profile', donor_id=donor_id)
        
        BloodRequest.objects.create(
            sender=request.user, receiver=receiver,
            patient_name=request.POST.get('patient_name'),
            blood_group=request.POST.get('blood_group'),
            city=request.POST.get('city'),
            hospital_name=request.POST.get('hospital_name'),
            message=request.POST.get('message'),
            duration=int(request.POST.get('duration', 1)),
            time_duration=f"{request.POST.get('duration', 1)} Hour"
        )
        messages.success(request, "Blood request sent successfully!")
        return redirect('history')
    cities = City.objects.all()
    from .models import BloodGroup
    blood_groups = [bg.name for bg in BloodGroup.objects.all()]
    return render(request, 'send_request.html', {
        'donor': receiver, 
        'cities': cities,
        'blood_groups': blood_groups
    })

@login_required
def my_requests_view(request):
    requests = BloodRequest.objects.filter(receiver=request.user, status='Pending').order_by('-created_at')
    return render(request, 'my_requests.html', {'requests': requests})

@login_required
def history_view(request):
    if request.user.profile.is_donor:
        requests = BloodRequest.objects.filter(receiver=request.user).exclude(status='Pending').order_by('-created_at')
    else:
        requests = BloodRequest.objects.filter(sender=request.user).order_by('-created_at')
    return render(request, 'history.html', {'requests': requests})

@login_required
def request_detail_view(request, pk):
    blood_request = get_object_or_404(BloodRequest, id=pk)
    # Only sender or receiver can see details
    if request.user != blood_request.sender and request.user != blood_request.receiver:
        messages.error(request, "You are not authorized to view this request.")
        return redirect('home')
        
    # Mark as acknowledged when sender views their accepted/rejected request details
    if request.user == blood_request.sender and blood_request.status in ['Accepted', 'Rejected'] and not blood_request.sender_acknowledged:
        blood_request.sender_acknowledged = True
        blood_request.save()
        
    return render(request, 'request_detail.html', {'req': blood_request})

@login_required
def recipient_action_view(request, request_id, action):
    blood_request = get_object_or_404(BloodRequest, id=request_id, sender=request.user)
    if blood_request.status == 'Accepted':
        blood_request.status = action
        blood_request.save()
        if action == 'Completed':
            messages.success(request, "Request marked as Completed. Thank you for confirming!")
        else:
            messages.warning(request, "Donor reported for not arriving.")
    else:
        messages.error(request, "Invalid action for this request.")
    return redirect('history')

@login_required
def update_request_status_view(request, request_id, status):
    blood_request = get_object_or_404(BloodRequest, id=request_id, receiver=request.user)
    
    donor_msg = request.POST.get('donor_response', '') if request.method == "POST" else ''
    blood_request.status = status
    if status == 'Accepted':
        blood_request.accepted_at = timezone.now()
        blood_request.donor_response = f"{donor_msg} (My Contact: {request.user.profile.phone_number})".strip()
    else:
        if donor_msg:
            blood_request.donor_response = donor_msg
            
    blood_request.save()

    # --- FULFILLMENT LOGIC (5 ACCEPTS = AUTO FULFILL OTHERS) ---
    if status == 'Accepted':
        # Find related requests for same patient, group, hospital sent by same sender
        related_requests = BloodRequest.objects.filter(
            sender=blood_request.sender,
            patient_name=blood_request.patient_name,
            blood_group=blood_request.blood_group,
            hospital_name=blood_request.hospital_name,
            status='Accepted'
        ).count()
        
        if related_requests >= 5:
            # Mark others as Fulfilled
            BloodRequest.objects.filter(
                sender=blood_request.sender,
                patient_name=blood_request.patient_name,
                blood_group=blood_request.blood_group,
                hospital_name=blood_request.hospital_name,
                status='Pending'
            ).update(status='Fulfilled')

    messages.success(request, f"Request {status} successfully!")
    return redirect('my_requests')

def ensure_cities():
    if not City.objects.exists():
        default_cities = [
            'Lahore', 'Karachi', 'Islamabad', 'Faisalabad', 'Multan', 'Peshawar', 'Bahawalpur', 'Sialkot', 
            'Gujranwala', 'Quetta', 'Sargodha', 'Sukkur', 'Jhang', 'Sheikhupura', 'Rahim Yar Khan', 'Gujrat', 
            'Mardan', 'Kasur', 'Sahiwal', 'Okara', 'Wah Cantonment', 'Dera Ghazi Khan'
        ]
        for name in default_cities:
            City.objects.get_or_create(name=name)

@login_required
def profile_settings_view(request):
    if request.method == "POST":
        user = request.user
        profile = user.profile
        user.first_name = request.POST.get('full_name')
        
        new_email = request.POST.get('email')
        if new_email and new_email != user.email:
            if User.objects.filter(email=new_email).exclude(pk=user.pk).exists():
                messages.error(request, "Email already registered by another user!")
                return redirect('profile_settings')
            user.email = new_email

        profile.phone_number = request.POST.get('phone_number')
        profile.city = request.POST.get('city')
        if request.FILES.get('image'):
            profile.image = request.FILES.get('image')
        user.save()
        profile.save()
        messages.success(request, "Profile updated successfully!")
        return redirect('profile_settings')
    
    ensure_cities()
    cities = City.objects.all()
    
    needs_health_warning = False
    latest_completed = BloodRequest.objects.filter(receiver=request.user, status='Completed').order_by('-id').first()
    if latest_completed:
        cleared_id = request.session.get('cleared_request_id', -1)
        if cleared_id != latest_completed.id:
            needs_health_warning = True
            
    return render(request, 'profile.html', {
        'cities': cities,
        'needs_health_warning': needs_health_warning,
        'latest_completed_id': latest_completed.id if latest_completed else -1
    })

@login_required
def change_password_view(request):
    if request.method == "POST":
        old_pass = request.POST.get('old_password')
        new_pass = request.POST.get('new_password')
        if request.user.check_password(old_pass):
            request.user.set_password(new_pass)
            request.user.save()
            update_session_auth_hash(request, request.user)
            messages.success(request, "Password changed successfully!")
        else:
            messages.error(request, "Incorrect old password.")
        return redirect('profile_settings')
    return render(request, 'profile.html') # Redirect to profile to show modal or form

@login_required
def toggle_availability_view(request):
    profile = request.user.profile
    state = request.GET.get('state')
    
    if state is not None:
        profile.available = state.lower() == 'true'
    else:
        profile.available = not profile.available
        
    clear_id = request.GET.get('clear_id')
    if clear_id and clear_id != 'null':
        request.session['cleared_request_id'] = int(clear_id)
        
    profile.save()
    return JsonResponse({'status': 'success', 'available': profile.available})

# --- AUTH ---
def signup_view(request):
    if request.method == "POST":
        data = request.POST
        if User.objects.filter(username=data.get('username')).exists():
            messages.error(request, "Username already exists!")
            return redirect('signup')
        if User.objects.filter(email=data.get('email')).exists():
            messages.error(request, "Email already registered!")
            return redirect('signup')
        user = User.objects.create_user(username=data.get('username'), email=data.get('email'), password=data.get('password'), first_name=data.get('full_name'))
        profile = Profile.objects.get(user=user)
        profile.phone_number = data.get('phone_number'); profile.city = data.get('city')
        profile.is_donor = (data.get('role') == 'donor')
        if profile.is_donor: profile.blood_group = data.get('blood_group')
        if request.FILES.get('image'): profile.image = request.FILES.get('image')
        profile.save()
        messages.success(request, "Account created! Please login.")
        return redirect('login')
    
    ensure_cities()
    cities = City.objects.all()
    from .models import BloodGroup
    blood_groups = [bg.name for bg in BloodGroup.objects.all()]
    return render(request, 'signup.html', {
        'cities': cities,
        'blood_groups': blood_groups
    })

def login_view(request):
    if request.user.is_authenticated: return redirect('home')
    if request.method == "POST":
        user = authenticate(username=request.POST.get('username'), password=request.POST.get('password'))
        if user:
            login(request, user)
            # Store selected role in session for Dual Mode
            role_selected = request.POST.get('role', 'donor' if user.profile.is_donor else 'recipient')
            request.session['current_role'] = role_selected
            return redirect('home')
        messages.error(request, "Invalid credentials!")
    return render(request, 'login.html')

def logout_view(request): logout(request); return redirect('landing')

# --- ADMIN ---
@staff_member_required
def admin_dashboard(request):
    total_users = User.objects.filter(is_superuser=False).count()
    total_donors = Profile.objects.filter(is_donor=True, user__is_superuser=False).count()
    total_recipients = Profile.objects.filter(is_donor=False, user__is_superuser=False).count()
    total_requests = BloodRequest.objects.count()
    pending_requests = BloodRequest.objects.filter(status='Pending').count()
    
    return render(request, 'admin/admin_dashboard.html', {
        'total_users': total_users,
        'total_donors': total_donors,
        'total_recipients': total_recipients,
        'total_requests': total_requests,
        'pending_requests': pending_requests,
        'all_requests': BloodRequest.objects.all().order_by('-created_at')[:5],
        'all_donors': Profile.objects.filter(is_donor=True, user__is_superuser=False).order_by('-user__date_joined')[:5],
    })

@staff_member_required
def admin_manage_cities(request):
    if request.method == "POST":
        City.objects.get_or_create(name=request.POST.get('city_name').strip())
        messages.success(request, "City added successfully!")
    cities = City.objects.all().order_by('name')
    return render(request, 'admin/manage_cities.html', {'cities': cities})

@staff_member_required
def admin_delete_city(request, city_id):
    city = get_object_or_404(City, id=city_id)
    city.delete()
    messages.success(request, f"City '{city.name}' deleted successfully!")
    return redirect('admin_manage_cities')

@staff_member_required
def admin_manage_blood_groups(request):
    from .models import BloodGroup
    if request.method == "POST":
        BloodGroup.objects.get_or_create(name=request.POST.get('group_name').strip())
        messages.success(request, "Blood group added successfully!")
    groups = BloodGroup.objects.all().order_by('name')
    return render(request, 'admin/manage_blood_groups.html', {'blood_groups': groups})

@staff_member_required
def admin_delete_blood_group(request, group_id):
    from .models import BloodGroup
    group = get_object_or_404(BloodGroup, id=group_id)
    group.delete()
    messages.success(request, f"Blood group '{group.name}' deleted successfully!")
    return redirect('admin_manage_blood_groups')

@staff_member_required
def admin_all_users(request):
    role = request.GET.get('role')
    users = User.objects.filter(is_superuser=False)
    if role == 'donor':
        users = users.filter(profile__is_donor=True)
    elif role == 'recipient':
        users = users.filter(profile__is_donor=False)
    users = users.order_by('-date_joined')
    return render(request, 'admin/admin_user_list.html', {'users': users, 'current_role': role})

@staff_member_required
def admin_user_detail(request, user_id):
    user_obj = get_object_or_404(User, id=user_id)
    return render(request, 'admin/admin_user_detail.html', {
        'user_obj': user_obj, 'all_sent': BloodRequest.objects.filter(sender=user_obj).order_by('-created_at'),
        'all_received': BloodRequest.objects.filter(receiver=user_obj).order_by('-created_at'),
    })

@staff_member_required
def admin_all_requests(request): return render(request, 'admin/admin_request_list.html', {'requests': BloodRequest.objects.all().order_by('-created_at')})

@staff_member_required
def admin_request_detail(request, request_id):
    blood_request = get_object_or_404(BloodRequest, id=request_id)
    return render(request, 'admin/admin_request_detail.html', {'req': blood_request})

@staff_member_required
def admin_profile_edit(request):
    user_obj = request.user
    profile_obj = user_obj.profile
    
    if request.method == "POST":
        user_obj.first_name = request.POST.get('first_name', '').strip()
        user_obj.last_name = request.POST.get('last_name', '').strip()
        user_obj.email = request.POST.get('email', '').strip()
        user_obj.save()
        
        profile_obj.phone_number = request.POST.get('phone_number', '').strip()
        profile_obj.city = request.POST.get('city', '')
        profile_obj.blood_group = request.POST.get('blood_group', '')
        
        if 'image' in request.FILES:
            profile_obj.image = request.FILES['image']
            
        profile_obj.save()
        messages.success(request, "Your profile has been updated successfully!")
        return redirect('admin_profile_edit')
        
    cities = City.objects.all().order_by('name')
    from .models import BloodGroup
    blood_groups = BloodGroup.objects.all().order_by('name')
    return render(request, 'admin/admin_profile.html', {
        'user_obj': user_obj,
        'profile_obj': profile_obj,
        'cities': cities,
        'blood_groups': blood_groups
    })