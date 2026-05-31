from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver

# --- CITY MODEL ---
class City(models.Model):
    name = models.CharField(max_length=100, unique=True)
    class Meta:
        verbose_name = 'City'
        verbose_name_plural = 'Cities'
    def __str__(self): return self.name

# --- BLOOD GROUP MODEL ---
class BloodGroup(models.Model):
    name = models.CharField(max_length=10, unique=True)
    class Meta:
        verbose_name = 'Blood Group'
        verbose_name_plural = 'Blood Groups'
    def __str__(self): return self.name

# --- PROFILE MODEL ---
class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    image = models.ImageField(upload_to='profile_pics/', default='default.jpg', blank=True, null=True)
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    blood_group = models.CharField(max_length=10, blank=True, null=True)
    city = models.CharField(max_length=50, blank=True, null=True) # Will keep as string for now to match current data
    is_donor = models.BooleanField(default=False)
    available = models.BooleanField(default=True)

    def __str__(self):
        return f'{self.user.username} Profile'

# --- BLOOD REQUEST MODEL ---
class BloodRequest(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_requests')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_requests')
    patient_name = models.CharField(max_length=100)
    blood_group = models.CharField(max_length=5)
    city = models.CharField(max_length=50)
    hospital_name = models.CharField(max_length=150)
    message = models.TextField()
    status = models.CharField(max_length=20, default='Pending') # Pending, Accepted, Rejected, Cancelled, Fulfilled
    created_at = models.DateTimeField(auto_now_add=True)
    donor_response = models.TextField(blank=True, null=True) 
    duration = models.IntegerField(default=1) # Duration in hours 
    time_duration = models.CharField(max_length=20, default='1 Hour')
    accepted_at = models.DateTimeField(blank=True, null=True)
    sender_acknowledged = models.BooleanField(default=False)

    @property
    def is_contact_visible(self):
        if not self.accepted_at or self.status != 'Accepted': return False
        from django.utils import timezone
        from datetime import timedelta
        return timezone.now() < self.accepted_at + timedelta(minutes=5)

    def __str__(self):
        return f"Request from {self.sender.username} to {self.receiver.username}"

# --- SIGNALS ---
@receiver(post_save, sender=User)
def create_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_profile(sender, instance, **kwargs):
    instance.profile.save()


def sync_flutter_constants():
    try:
        import os
        from django.conf import settings
        base_dir = settings.BASE_DIR
        flutter_constants_path = os.path.abspath(os.path.join(base_dir, '..', '..', 'bloodlink_flutter', 'lib', 'utils', 'Constants.dart'))
        
        if not os.path.exists(os.path.dirname(flutter_constants_path)):
            return
            
        cities = list(City.objects.all().order_by('name').values_list('name', flat=True))
        blood_groups = list(BloodGroup.objects.all().values_list('name', flat=True))
        
        cities_lines = ",\n".join([f"    '{c}'" for c in cities])
        bg_lines = ", ".join([f"'{g}'" for g in blood_groups])
        
        content = f"""class AppConstants {{
  static const List<String> cities = [
{cities_lines}
  ];

  static const List<String> bloodGroups = [
    {bg_lines}
  ];
}}
"""
        with open(flutter_constants_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception as e:
        print(f"Error syncing Constants.dart: {e}")


@receiver(post_save, sender=City)
@receiver(post_delete, sender=City)
@receiver(post_save, sender=BloodGroup)
@receiver(post_delete, sender=BloodGroup)
def handle_constants_sync(sender, **kwargs):
    sync_flutter_constants()
