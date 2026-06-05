from rest_framework import viewsets, permissions, status, generics
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q
from .models import Profile, BloodRequest, City, BloodGroup
from .serializers import (
    UserSerializer, ProfileSerializer, BloodRequestSerializer, CitySerializer,
    BloodGroupSerializer
)
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        serializer = UserSerializer(self.user, context={
            'request': self.context.get('request'),
            'user': self.user
        }).data
        for k, v in serializer.items():
            data[k] = v
        return data

class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

@api_view(['GET'])
def get_cities(request):
    cities = City.objects.all().order_by('name')
    serializer = CitySerializer(cities, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def get_blood_groups(request):
    groups = BloodGroup.objects.all()
    serializer = BloodGroupSerializer(groups, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def register_user(request):
    data = request.data
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    phone_number = data.get('phone_number')
    city = data.get('city')
    role = data.get('role')
    
    if not username:
        return Response({'detail': 'Username is required.'}, status=status.HTTP_400_BAD_REQUEST)
    if not email:
        return Response({'detail': 'Email is required.'}, status=status.HTTP_400_BAD_REQUEST)
    if not password:
        return Response({'detail': 'Password is required.'}, status=status.HTTP_400_BAD_REQUEST)
    if not phone_number:
        return Response({'detail': 'Phone number is required.'}, status=status.HTTP_400_BAD_REQUEST)
    if not city:
        return Response({'detail': 'City is required.'}, status=status.HTTP_400_BAD_REQUEST)
    if not role:
        return Response({'detail': 'Role is required.'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(username=username).exists():
        return Response({'detail': 'Username already exists!'}, status=status.HTTP_400_BAD_REQUEST)

    if User.objects.filter(email=email).exists():
        return Response({'detail': 'Email already registered!'}, status=status.HTTP_400_BAD_REQUEST)
        
    try:
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            first_name=data.get('full_name', ''),
        )
        
        profile = user.profile
        profile.phone_number = phone_number
        profile.city = city
        
        if role == 'donor':
            profile.is_donor = True
            profile.blood_group = data.get('blood_group')
            profile.available = True
        
        if 'image' in request.FILES:
            profile.image = request.FILES['image']
            
        profile.save()
        
        serializer = UserSerializer(user, many=False, context={'request': request, 'user': user})
        return Response(serializer.data)
    except Exception as e:
        message = {'detail': str(e)}
        return Response(message, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_donors(request):
    blood_group = request.query_params.get('blood_group')
    city = request.query_params.get('city')
    
    donors = Profile.objects.filter(is_donor=True, available=True).exclude(user=request.user)
    
    if blood_group:
        donors = donors.filter(blood_group=blood_group)
    if city:
        donors = donors.filter(city__icontains=city)
        
    serializer = ProfileSerializer(donors, many=True, context={'request': request})
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def send_blood_request(request):
    user = request.user
    data = request.data
    receiver_id = data.get('receiver_id')
    
    # Limit Check (10 requests)
    pending_count = BloodRequest.objects.filter(sender=user, status='Pending').count()
    if pending_count >= 10:
        return Response({'detail': 'Limit Reached! You have 10 pending requests.'}, status=status.HTTP_400_BAD_REQUEST)
        
    receiver = User.objects.get(id=receiver_id)
    
    # Check for existing pending request to this donor
    existing_request = BloodRequest.objects.filter(sender=user, receiver=receiver, status='Pending').exists()
    if existing_request:
        return Response({'detail': 'A pending request already exists for this donor.'}, status=status.HTTP_400_BAD_REQUEST)
    
    blood_request = BloodRequest.objects.create(
        sender=user,
        receiver=receiver,
        patient_name=data.get('patient_name'),
        blood_group=data.get('blood_group'),
        city=data.get('city'),
        hospital_name=data.get('hospital_name'),
        message=data.get('message'),
        duration=int(data.get('duration', 1)),
        time_duration=f"{data.get('duration', 1)} Hour"
    )
    
    serializer = BloodRequestSerializer(blood_request, many=False)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_my_requests(request):
    user = request.user
    role = request.query_params.get('role', 'receiver' if user.profile.is_donor else 'sender')
    status_filter = request.query_params.get('status', 'Pending') # Default to Pending for Home
    
    if role == 'all':
        # History Screen: fetch BOTH sent and received requests for the user
        requests = BloodRequest.objects.filter(
            Q(sender=user) | Q(receiver=user)
        ).order_by('-created_at')
    elif role == 'receiver':
        requests = BloodRequest.objects.filter(receiver=user).order_by('-created_at')
    else:
        requests = BloodRequest.objects.filter(sender=user).order_by('-created_at')
    
    # Filter by status
    if status_filter == 'Pending':
        if role == 'receiver':
            requests = requests.filter(Q(status='Pending') | Q(status='Accepted') | Q(status='Completed'))
        elif role == 'all':
            pass  # Return all statuses for History
        else:
            requests = requests.filter(Q(status='Pending') | Q(status__in=['Accepted', 'Rejected'], sender_acknowledged=False))
    elif status_filter == 'History':
        # For History screen, we return all statuses (Pending, Accepted, Rejected, etc.)
        pass
    else:
        # Support specific status filtering for mobile tabs (Accepted, Rejected, etc.)
        requests = requests.filter(status=status_filter)
        
    # Expiration Logic
    now = timezone.now()
    for req in requests:
        if req.status == 'Pending':
            expire_time = req.created_at + timedelta(hours=req.duration)
            if now > expire_time:
                req.status = 'Cancelled'
                req.save()
                
    serializer = BloodRequestSerializer(requests, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def update_request_status(request):
    user = request.user
    data = request.data
    req_id = data.get('id')
    new_status = data.get('status') # 'Accepted' or 'Rejected'
    response_msg = data.get('message', '')
    
    blood_request = BloodRequest.objects.get(id=req_id, receiver=user)
    blood_request.status = new_status
    
    if new_status == 'Accepted':
        blood_request.accepted_at = timezone.now()
        donor_phone = user.profile.phone_number
        blood_request.donor_response = f"{response_msg} (My Contact: {donor_phone})"
        
        # Fulfillment Logic (5 accepts)
        related_accepted = BloodRequest.objects.filter(
            sender=blood_request.sender,
            patient_name=blood_request.patient_name,
            blood_group=blood_request.blood_group,
            hospital_name=blood_request.hospital_name,
            status='Accepted'
        ).count()
        
        if related_accepted >= 5:
            BloodRequest.objects.filter(
                sender=blood_request.sender,
                patient_name=blood_request.patient_name,
                blood_group=blood_request.blood_group,
                hospital_name=blood_request.hospital_name,
                status='Pending'
            ).update(status='Fulfilled')
    else:
        blood_request.donor_response = response_msg
        
    blood_request.save()
    return Response({'detail': f'Request {new_status}'})


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def recipient_request_action(request):
    user = request.user
    req_id = request.data.get('id')
    action = request.data.get('action') # 'Completed' or 'Reported'
    
    try:
        blood_request = BloodRequest.objects.get(id=req_id, sender=user)
        if blood_request.status != 'Accepted':
            return Response({'detail': 'Only accepted requests can be modified'}, status=status.HTTP_400_BAD_REQUEST)
        
        blood_request.status = action
        blood_request.save()
        return Response({'detail': f'Request marked as {action}'})
    except BloodRequest.DoesNotExist:
        return Response({'detail': 'Request not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def update_profile(request):
    user = request.user
    data = request.data
    
    email = data.get('email')
    if email and email != user.email:
        if User.objects.filter(email=email).exclude(pk=user.pk).exists():
            return Response({'detail': 'Email already registered by another user!'}, status=status.HTTP_400_BAD_REQUEST)
        user.email = email
        
    user.first_name = data.get('full_name', user.first_name)
    user.save()
    
    profile = user.profile
    profile.phone_number = data.get('phone_number', profile.phone_number)
    profile.city = data.get('city', profile.city)
    if 'available' in data:
        val = data.get('available')
        if isinstance(val, str):
            profile.available = val.lower() == 'true'
        else:
            profile.available = bool(val)
    
    if 'image' in request.FILES:
        profile.image = request.FILES['image']
        
    profile.save()
    
    serializer = UserSerializer(user, many=False, context={'request': request, 'user': user})
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def verify_password(request):
    user = request.user
    password = request.data.get('password')
    if user.check_password(password):
        return Response({'detail': 'Verified'})
    return Response({'detail': 'Invalid Password'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def change_password_api(request):
    user = request.user
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')
    
    if not old_password or not new_password:
        return Response({'detail': 'Both old and new passwords are required.'}, status=status.HTTP_400_BAD_REQUEST)
        
    if not user.check_password(old_password):
        return Response({'detail': 'Incorrect old password.'}, status=status.HTTP_400_BAD_REQUEST)
        
    user.set_password(new_password)
    user.save()
    return Response({'detail': 'Password changed successfully!'})

@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def acknowledge_request(request):
    req_id = request.data.get('id')
    try:
        blood_request = BloodRequest.objects.get(id=req_id, sender=request.user)
        blood_request.sender_acknowledged = True
        blood_request.save()
        return Response({'detail': 'Request marked as acknowledged.'})
    except BloodRequest.DoesNotExist:
        return Response({'detail': 'Request not found.'}, status=status.HTTP_404_NOT_FOUND)
