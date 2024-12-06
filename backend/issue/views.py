from authentication.views import AuthenticationView
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import *
from .models import Issue, Tag
from django.db import transaction
from django.db.models import F
from itertools import chain


class ShowUserIssuesView(APIView):
    authentication_classes = [AuthenticationView]

    def get(self, request):
        user = request.user

        user_issues = Issue.objects.filter(author=user)

        issues_data = [
            {
                "id": issue.id,
                "title": issue.title,
                "description": issue.description,
                "status": issue.status,
                "tags": [tag.name for tag in issue.tags.all()],
                "vote_count": issue.vote_count,
                "location": issue.location,
                "created_at": issue.created_at,
                "updated_at": issue.updated_at,
            }
            for issue in user_issues
        ]

        return Response(
            {
                "message": "User's issues retrieved successfully.",
                "issues": issues_data,
            },
            status=status.HTTP_200_OK,
        )


class CreateIssueView(APIView):
    #authentication_classes = [AuthenticationView]
    authentication_classes = []

    def post(self, request):
        #user = request.user
        user = User.objects.get(id=1) 
        uid = request.POST.get('uid')
        print(uid)

        title = request.POST.get('title')  # Changed from `request.data.get`
        description = request.POST.get('description')  # Changed from `request.data.get`
        tags = request.POST.get('tags', '[]')  # Changed from `request.data.get`
        location = request.POST.get('location', None)  # Changed from `request.data.get`
        image = request.FILES.get('image', None)
        
        print(title)
        print(description)
        print(tags)
        print(location)
        print(image)
        

        if not title or not description:
            return Response(
                {"error": "Title and description are required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        tag_objects = []
        for tag_name in tags:
            tag, created = Tag.objects.get_or_create(name=tag_name)
            tag_objects.append(tag)

        issue = Issue.objects.create(
            title=title,
            description=description,
            location=location,
            author=user,
        )

        if image:
            issue.image.save(image.name, image)

        issue.tags.set(tag_objects)
        issue.save()

        return Response(
            {
                "message": "Issue created successfully.",
                "issue_id": issue.id,
                "title": issue.title,
                "description": issue.description,
                "tags": [tag.name for tag in issue.tags.all()],
                "location": issue.location,
                "author": issue.author.username,
                "created_at": issue.created_at,
            },
            status=status.HTTP_201_CREATED,
        )
        

class LeaderboardView(APIView):

    def get(self, request):
        issues = Issue.objects.all()

        leaderboard_data = [
            {
                "id": issue.id,
                "title": issue.title,
                "description": issue.description,
                "upvote_count": Vote.objects.filter(issue=issue).count(),  # Calculate upvotes dynamically
                "downvote_count": DownVote.objects.filter(issue=issue).count(),  # Calculate downvotes dynamically
                "status": issue.status,
                "tags": [tag.name for tag in issue.tags.all()],
                "author": issue.author.username,
                "location": issue.location,
                "created_at": issue.created_at.strftime('%Y-%m-%d %H:%M'),
                "updated_at": issue.updated_at,
                "imageUrl": issue.image.url if issue.image else None,
            }
            for issue in issues
        ]

        # Sort by upvote_count in descending order
        leaderboard_data = sorted(leaderboard_data, key=lambda x: x["upvote_count"], reverse=True)

        return Response(
            {
                "message": "Leaderboard retrieved successfully.",
                "leaderboard": leaderboard_data,
            },
            status=status.HTTP_200_OK,
        )
      
from django.db import transaction
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Issue, Vote, DownVote

class UpVoteView(APIView):
    authentication_classes = []

    def post(self, request):
        user = User.objects.get(id=1)  # Replace with request.user in real scenario
        issue_id = request.data.get("issue_id")
        upvoted = request.data.get("upvoted")  # Boolean value from the frontend

        if not issue_id:
            return Response(
                {"error": "Issue ID is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if upvoted is None:
            return Response(
                {"error": "Upvoted flag is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            issue = Issue.objects.get(id=issue_id)
        except Issue.DoesNotExist:
            return Response(
                {"error": "Issue not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        with transaction.atomic():
            # Handle upvote logic
            if upvoted:
                if not Vote.objects.filter(issue=issue, user=user).exists():
                    Vote.objects.create(issue=issue, user=user)
                    DownVote.objects.filter(issue=issue, user=user).delete()
            else:
                Vote.objects.filter(issue=issue, user=user).delete()

        # Calculate new vote counts
        upvote_count = Vote.objects.filter(issue=issue).count()
        downvote_count = DownVote.objects.filter(issue=issue).count()

        return Response(
            {
                "message": "Vote updated successfully.",
                "issue_id": issue.id,
                "upvote_count": upvote_count,
                "downvote_count": downvote_count,
            },
            status=status.HTTP_200_OK,
        )


from django.db import transaction
from django.db.models import F
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Issue

class DownVoteView(APIView):
    authentication_classes = []

    def post(self, request):
        user = User.objects.get(id=1)  # Replace with request.user in real scenario
        issue_id = request.data.get("issue_id")
        downvoted = request.data.get("downvoted")  # Boolean value from the frontend

        if not issue_id:
            return Response(
                {"error": "Issue ID is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if downvoted is None:
            return Response(
                {"error": "Downvoted flag is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            issue = Issue.objects.get(id=issue_id)
        except Issue.DoesNotExist:
            return Response(
                {"error": "Issue not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        with transaction.atomic():
            # Handle downvote logic
            if downvoted:
                if not DownVote.objects.filter(issue=issue, user=user).exists():
                    DownVote.objects.create(issue=issue, user=user)
                    Vote.objects.filter(issue=issue, user=user).delete()
            else:
                DownVote.objects.filter(issue=issue, user=user).delete()

        # Calculate new vote counts
        upvote_count = Vote.objects.filter(issue=issue).count()
        downvote_count = DownVote.objects.filter(issue=issue).count()

        return Response(
            {
                "message": "Vote updated successfully.",
                "issue_id": issue.id,
                "upvote_count": upvote_count,
                "downvote_count": downvote_count,
            },
            status=status.HTTP_200_OK,
        )

class NotDownVoteView(APIView):
    authentication_classes = []

    def post(self, request):
        user = User.objects.get(id=1)  # Replace with `request.user` in production
        issue_id = request.data.get("issue_id")

        if not issue_id:
            return Response(
                {"error": "Issue ID is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            issue = Issue.objects.get(id=issue_id)
        except Issue.DoesNotExist:
            return Response(
                {"error": "Issue not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        downvote = issue.downvote_set.filter(user=user).first()
        if not downvote:
            return Response(
                {"error": "You have not downvoted this issue."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            issue.vote_count = F("vote_count") - 1
            issue.save()
            downvote.delete()

        issue.refresh_from_db()

        return Response(
            {
                "message": "Downvote removed successfully.",
                "issue_id": issue.id,
                "new_vote_count": issue.vote_count,
            },
            status=status.HTTP_200_OK,
        )


from django.db.models import Count
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Tag, Vote, DownVote

class ShowTagWiseIssuesView(APIView):
    # authentication_classes = [AuthenticationView]
    authentication_classes = []

    def post(self, request):
        # user = request.user
        user = User.objects.get(id=1)  # Replace with authenticated user in production
        tag_name = request.data.get("tag")

        if tag_name == "Water Supply":
            tag_name = "Water"
        
        print(tag_name)

        if not tag_name:
            return Response(
                {"error": "Tag is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            tag = Tag.objects.get(name=tag_name)
        except Tag.DoesNotExist:
            print("not found")
            return Response(
                {"error": f"Tag '{tag_name}' not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        tag_issues = tag.issue_tag.all()  # Using related_name

        issues_data = [
            {
                "id": issue.id,
                "title": issue.title,
                "description": issue.description,
                "status": issue.status,
                "tags": [t.name for t in issue.tags.all()],
                "upvote_count": Vote.objects.filter(issue=issue).count(),  # Count unique upvotes
                "downvote_count": DownVote.objects.filter(issue=issue).count(),  # Count unique downvotes
                "location": issue.location,
                "created_at": issue.created_at.strftime('%Y-%m-%d %H:%M'),
                "updated_at": issue.updated_at,
                "voted": Vote.objects.filter(issue=issue, user=user).exists(),  # Check if the user has voted
                "downvoted": DownVote.objects.filter(issue=issue, user=user).exists(),  # Check if the user has downvoted
                "imageUrl": issue.image.url if issue.image else None,
            }
            for issue in tag_issues
        ]

        print(issues_data)

        return Response(
            {
                "message": f"Issues for tag '{tag_name}' retrieved successfully.",
                "issues": issues_data,
            },
            status=status.HTTP_200_OK,
        )


from django.db.models import Q
from itertools import chain
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Issue, Comment, Vote, DownVote


class ActivityHistoryView(APIView):
    authentication_classes = []  # Replace with actual authentication in production

    def get(self, request):
        user = User.objects.get(id=1)  # Replace with `request.user` in production
        print("xx")
        # Query all activities
        user_issues = Issue.objects.filter(author=user).values(
            "id", "title", "created_at", "updated_at", "description", "vote_count", "status"
        )
        user_comments = Comment.objects.filter(user=user).values(
            "id", "issue_id", "text", "created_at"
        )
        user_upvotes = Vote.objects.filter(user=user).values(
            "id", "issue_id", "issue__title", "issue__author__username", "issue__created_at"
        )
        user_downvotes = DownVote.objects.filter(user=user).values(
            "id", "issue_id", "issue__title", "issue__author__username", "issue__created_at"
        )

        # Prepare activities with a common structure for sorting
        activities = []

        for issue in user_issues:
            activities.append({
                "type": "Issue Raised",
                "details": {
                    "id": issue["id"],
                    "title": issue["title"],
                    "description": issue["description"],
                    "status": issue["status"],
                    "vote_count": issue["vote_count"],
                    "timestamp": issue["created_at"],
                },
            })

        for comment in user_comments:
            activities.append({
                "type": "Comment",
                "details": {
                    "id": comment["id"],
                    "issue_id": comment["issue_id"],
                    "text": comment["text"],
                    "timestamp": comment["created_at"],
                },
            })

        for upvote in user_upvotes:
            activities.append({
                "type": "Upvote",
                "details": {
                    "id": upvote["id"],
                    "issue_id": upvote["issue_id"],
                    "issue_title": upvote["issue__title"],
                    "author": upvote["issue__author__username"],
                    "timestamp": upvote["issue__created_at"],
                },
            })

        for downvote in user_downvotes:
            activities.append({
                "type": "Downvote",
                "details": {
                    "id": downvote["id"],
                    "issue_id": downvote["issue_id"],
                    "issue_title": downvote["issue__title"],
                    "author": downvote["issue__author__username"],
                    "timestamp": downvote["issue__created_at"],
                },
            })

        # Sort all activities by timestamp (latest first)
        activities = sorted(activities, key=lambda x: x["details"]["timestamp"], reverse=True)
        print(activities)

        return Response(
            {
                "message": "Activity history retrieved successfully.",
                "activities": activities,
            },
            status=status.HTTP_200_OK,
        )
