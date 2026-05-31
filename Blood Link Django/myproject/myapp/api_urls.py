from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .api_views import (
    register_user, get_donors, send_blood_request, 
    get_my_requests, update_request_status, update_profile, 
    verify_password, change_password_api, MyTokenObtainPairView, get_cities,
    acknowledge_request, get_blood_groups
)
from rest_framework_simplejwt.views import TokenRefreshView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('cities/', get_cities, name='api_get_cities'),
    path('blood-groups/', get_blood_groups, name='api_get_blood_groups'),
    path('register/', register_user, name='api_register'),
    path('login/', MyTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    path('donors/', get_donors, name='api_get_donors'),
    path('requests/send/', send_blood_request, name='api_send_request'),
    path('requests/my/', get_my_requests, name='api_get_my_requests'),
    path('requests/update/', update_request_status, name='api_update_request'),
    path('requests/acknowledge/', acknowledge_request, name='api_acknowledge_request'),
    
    path('profile/update/', update_profile, name='api_update_profile'),
    path('password/verify/', verify_password, name='api_verify_password'),
    path('password/change/', change_password_api, name='api_change_password'),

    # API Documentation
    path('schema/', SpectacularAPIView.as_view(), name='schema'),
    path('docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]
