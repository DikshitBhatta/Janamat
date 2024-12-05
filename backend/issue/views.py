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

        title = request.data.get('title')
        description = request.data.get('description')
        tags = request.data.get('tags', []) 
        location = request.data.get('location', None)
        image = request.FILES.get('image', None)

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
        issues = Issue.objects.all().order_by('-vote_count')

        leaderboard_data = [
            {
                "id": issue.id,
                "title": issue.title,
                "description": issue.description,
                "vote_count": issue.vote_count,
                "status": issue.status,
                "tags": [tag.name for tag in issue.tags.all()],
                "author": issue.author.username,
                "location": issue.location,
                "created_at": issue.created_at,
                "updated_at": issue.updated_at,
                "vote_count": issue.vote_count
            }
            for issue in issues
        ]

        return Response(
            {
                "message": "Leaderboard retrieved successfully.",
                "leaderboard": leaderboard_data,
            },
            status=status.HTTP_200_OK,
        )
        

class UpVoteView(APIView):
    authentication_classes = [AuthenticationView]

    def post(self, request):
        user = request.user
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

        if issue.vote_set.filter(user=user).exists():
            return Response(
                {"error": "You have already upvoted this issue."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            issue.vote_count = F("vote_count") + 1
            issue.save()

            issue.vote_set.create(user=user)

        issue.refresh_from_db()

        return Response(
            {
                "message": "Upvote successful.",
                "issue_id": issue.id,
                "new_vote_count": issue.vote_count,
            },
            status=status.HTTP_200_OK,
        )


class ShowTagWiseIssuesView(APIView):
    #authentication_classes = [AuthenticationView]
    authentication_classes = []

    def post(self, request):
        user = request.user
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
        print(tag_issues)

        issues_data = [
            {
                "id": issue.id,
                "title": issue.title,
                "description": issue.description,
                "status": issue.status,
                "tags": [t.name for t in issue.tags.all()],
                "vote_count": issue.vote_count,
                "location": issue.location,
                "created_at": issue.created_at,
                "updated_at": issue.updated_at,
                #"voted": issue.vote_set.filter(user=user).exists(),  # Check if the user has voted
            }
            for issue in tag_issues
        ]

        return Response(
            {
                "message": f"Issues for tag '{tag_name}' retrieved successfully.",
                "issues": issues_data,
            },
            status=status.HTTP_200_OK,
        )


class ActivityHistoryView(APIView):
    authentication_classes = [AuthenticationView]

    def get(self, request):
        user = request.user

        # Fetch user's created issues
        user_issues = Issue.objects.filter(author=user).values(
            'id',
            'title',
            'created_at'
        ).annotate(
            activity_type=F('status'),  # Activity type for issue creation
            activity="Created Issue"
        )

        # Fetch user's upvotes
        user_upvotes = user.vote_set.all().select_related('issue').values(
            id=F('issue__id'),
            title=F('issue__title'),
            created_at=F('issue__created_at')
        ).annotate(
            activity_type="Upvoted",
            activity="Upvoted an Issue"
        )

        # Fetch user's comments
        user_comments = Comment.objects.filter(user=user).select_related('issue').values(
            id=F('issue__id'),
            title=F('issue__title'),
            created_at=F('created_at')
        ).annotate(
            activity_type="Commented",
            activity="Commented on Issue"
        )

        # Combine all activities and sort by created_at timestamp
        activities = sorted(
            chain(user_issues, user_upvotes, user_comments),
            key=lambda x: x['created_at'],
            reverse=True  # Latest first
        )

        return Response(
            {
                "message": "User activity history retrieved successfully.",
                "activities": [
                    {
                        "issue_id": activity['id'],
                        "issue_title": activity['title'],
                        "activity": activity['activity'],
                        "timestamp": activity['created_at']
                    }
                    for activity in activities
                ],
            },
            status=status.HTTP_200_OK,
        )
        

   
        
