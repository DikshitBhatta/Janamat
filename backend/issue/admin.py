from django.contrib import admin

from django.contrib import admin
from .models import Tag, Issue, Comment, Vote

@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')  # Customize columns shown in admin list view

@admin.register(Issue)
class IssueAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'author', 'status', 'vote_count', 'created_at')
    search_fields = ('title', 'description', 'author__username')  # Enable search
    list_filter = ('status', 'tags', 'created_at')  # Enable filtering
    ordering = ('-created_at',)  # Order by creation date by default

@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ('id', 'issue', 'user', 'text', 'created_at')
    search_fields = ('text', 'user__username', 'issue__title')
    ordering = ('-created_at',)

@admin.register(Vote)
class VoteAdmin(admin.ModelAdmin):
    list_display = ('id', 'issue', 'user')
