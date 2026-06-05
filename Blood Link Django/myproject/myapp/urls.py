from django.urls import path
from . import views

urlpatterns = [
    # 🚀 LANDING & DASHBOARD
    path('', views.landing_view, name='landing'),
    path('home/', views.home_view, name='home'),
    
    # 🩸 BLOOD REQUESTS & SEARCH
    path('search/', views.search_donors_view, name='search_donors'),
    path('donor/<int:donor_id>/', views.donor_profile_view, name='donor_profile'),
    path('send-request/<int:donor_id>/', views.send_blood_request_view, name='send_blood_request'),
    path('my-requests/', views.my_requests_view, name='my_requests'),
    path('history/', views.history_view, name='history'),
    path('update-request/<int:request_id>/<str:status>/', views.update_request_status_view, name='update_request_status'),
    path('recipient-action/<int:request_id>/<str:action>/', views.recipient_action_view, name='recipient_action'),
    path('request-detail/<int:pk>/', views.request_detail_view, name='request_detail'),
    
    # 👤 PROFILE & SETTINGS
    path('profile/', views.profile_settings_view, name='profile_settings'),
    path('change-password/', views.change_password_view, name='change_password'),
    path('toggle-availability/', views.toggle_availability_view, name='toggle_availability'),
    
    # 🔐 AUTH
    path('signup/', views.signup_view, name='signup'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    
    # 🛡️ ADMIN PANEL
    path('admin-panel/', views.admin_dashboard, name='admin_dashboard'),
    path('admin-panel/users/', views.admin_all_users, name='admin_all_users'),
    path('admin-panel/users/<int:user_id>/', views.admin_user_detail, name='admin_user_detail'),
    path('admin-panel/requests/', views.admin_all_requests, name='admin_all_requests'),
    path('admin-panel/requests/<int:request_id>/', views.admin_request_detail, name='admin_request_detail'),
    path('admin-panel/cities/', views.admin_manage_cities, name='admin_manage_cities'),
    path('admin-panel/cities/delete/<int:city_id>/', views.admin_delete_city, name='admin_delete_city'),
    path('admin-panel/blood-groups/', views.admin_manage_blood_groups, name='admin_manage_blood_groups'),
    path('admin-panel/blood-groups/delete/<int:group_id>/', views.admin_delete_blood_group, name='admin_delete_blood_group'),
    path('admin-panel/profile/', views.admin_profile_edit, name='admin_profile_edit'),
]