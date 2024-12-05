from django.db import models

class User(models.Model):
    firebase_uid = models.CharField(max_length=128, unique=True)
    username = models.CharField(max_length=50, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
