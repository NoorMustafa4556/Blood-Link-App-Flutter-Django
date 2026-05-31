from rest_framework import serializers
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
from .models import Profile, BloodRequest, City, BloodGroup

class CitySerializer(serializers.ModelSerializer):
    class Meta:
        model = City
        fields = '__all__'

class BloodGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = BloodGroup
        fields = '__all__'

class ProfileSerializer(serializers.ModelSerializer):
    email = serializers.SerializerMethodField()
    username = serializers.CharField(source='user.username', read_only=True)
    full_name = serializers.CharField(source='user.first_name', read_only=True)
    has_pending_request = serializers.SerializerMethodField()
    phone_number = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = '__all__'

    def get_email(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            if obj.user == request.user:
                return obj.user.email
        return "Hidden (Shared on acceptance)"

    def get_phone_number(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            if obj.user == request.user:
                return obj.phone_number
        return "Hidden (Shared on acceptance)"

    def get_has_pending_request(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return BloodRequest.objects.filter(sender=request.user, receiver=obj.user, status='Pending').exists()
        return False

class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer(read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'profile']

class BloodRequestSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source='sender.first_name', read_only=True)
    receiver_name = serializers.CharField(source='receiver.first_name', read_only=True)
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    receiver_username = serializers.CharField(source='receiver.username', read_only=True)
    sender_phone = serializers.CharField(source='sender.profile.phone_number', read_only=True)
    sender_email = serializers.EmailField(source='sender.email', read_only=True)
    sender_city = serializers.CharField(source='sender.profile.city', read_only=True)
    is_contact_visible = serializers.BooleanField(read_only=True)
    minutes_left = serializers.SerializerMethodField()

    def get_minutes_left(self, obj):
        now = timezone.now()
        expires = obj.created_at + timedelta(hours=obj.duration)
        diff = expires - now
        total_seconds = diff.total_seconds()
        if total_seconds > 0:
            return int(total_seconds / 60)
        return 0

    class Meta:
        model = BloodRequest
        fields = [
            'id', 'sender', 'receiver', 'patient_name', 'blood_group', 'city', 
            'hospital_name', 'message', 'status', 'created_at', 'donor_response', 
            'duration', 'time_duration', 'accepted_at', 'is_contact_visible',
            'sender_name', 'receiver_name', 'sender_username', 'receiver_username', 
            'sender_phone', 'sender_email', 'sender_city', 'minutes_left', 'sender_acknowledged'
        ]
