from django.db import models
from authentication.models import User

class Tag(models.Model):
    name = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.name

class Issue(models.Model):
    STATUS_CHOICES = [
        ('open', 'Open'),
        ('in_progress', 'In Progress'),
        ('resolved', 'Resolved'),
    ]

    title = models.CharField(max_length=255)
    description = models.TextField()
    image = models.ImageField(upload_to='issue_images/', blank=True, null=True)
    vote_count = models.IntegerField(default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    tags = models.ManyToManyField(Tag, blank=True, related_name='issue_tag')
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name='auther_issue')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    location = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.title

class Comment(models.Model):
    issue = models.ForeignKey(Issue, on_delete=models.CASCADE, related_name='comments')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='comments')
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Comment by {self.user.username} on {self.issue.title}"
    
class Vote(models.Model):
    issue = models.ForeignKey(Issue, on_delete=models.CASCADE, related_name="vote_set")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="user_votes")
    
    class Meta:
        unique_together = ("issue","user")
        




