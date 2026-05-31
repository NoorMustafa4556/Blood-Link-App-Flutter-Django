from django.contrib import admin
from django.contrib.auth.models import User
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.forms import UserChangeForm, UserCreationForm
from django import forms
from .models import Profile, BloodRequest, City, BloodGroup

class MyUserChangeForm(UserChangeForm):
    def clean_email(self):
        email = self.cleaned_data.get('email')
        if email:
            if User.objects.filter(email__iexact=email).exclude(pk=self.instance.pk).exists():
                raise ValidationError("This email address is already registered by another user.")
        return email

class MyUserCreationForm(UserCreationForm):
    def clean_email(self):
        email = self.cleaned_data.get('email')
        if email:
            if User.objects.filter(email__iexact=email).exists():
                raise ValidationError("This email address is already registered.")
        return email

admin.site.unregister(User)


@admin.register(City)
class CityAdmin(admin.ModelAdmin):
    list_display = ['name']


@admin.register(BloodGroup)
class BloodGroupAdmin(admin.ModelAdmin):
    list_display = ['name']


class ProfileAdminForm(forms.ModelForm):
    blood_group = forms.ModelChoiceField(
        queryset=BloodGroup.objects.all(),
        required=False,
        to_field_name='name',
        empty_label="Select Blood Group"
    )
    class Meta:
        model = Profile
        fields = '__all__'


class ProfileInline(admin.StackedInline):
    model = Profile
    can_delete = False
    form = ProfileAdminForm
    verbose_name_plural = 'Profile Info'


@admin.register(User)
class MyUserAdmin(BaseUserAdmin):
    form = MyUserChangeForm
    add_form = MyUserCreationForm
    inlines = [ProfileInline]


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    form = ProfileAdminForm
    list_display = ['user', 'blood_group', 'city', 'is_donor', 'available', 'phone_number']
    list_filter = ['blood_group', 'city', 'is_donor', 'available']
    search_fields = ['user__username', 'phone_number']


class BloodRequestAdminForm(forms.ModelForm):
    blood_group = forms.ModelChoiceField(
        queryset=BloodGroup.objects.all(),
        required=False,
        to_field_name='name',
        empty_label="Select Blood Group"
    )
    class Meta:
        model = BloodRequest
        fields = '__all__'


@admin.register(BloodRequest)
class BloodRequestAdmin(admin.ModelAdmin):
    form = BloodRequestAdminForm
    list_display = ['sender', 'receiver', 'patient_name', 'blood_group', 'status', 'created_at']
    list_filter = ['status', 'blood_group', 'city']
    search_fields = ['patient_name', 'hospital_name']