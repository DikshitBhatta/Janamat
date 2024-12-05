from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'firebase_uid', 'username', 'created_at', 'updated_at')  
    search_fields = ('firebase_uid', 'username')  
    ordering = ('-created_at',)  
    list_filter = ('created_at', 'updated_at')  
