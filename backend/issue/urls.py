from django.urls import path
from .views import *

urlpatterns = [
    path("createissue/" , CreateIssueView.as_view(), name="create issue"),
    path("showissues/", ShowUserIssuesView.as_view(), name="show-issues"),
    path("issuewithtag/", ShowTagWiseIssuesView.as_view(), name="show-issues-with-tag"),
    path("leaderboard/", LeaderboardView.as_view(), name="leaderboard"),
    
]