from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User
import logging
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

logger = logging.getLogger(__name__)

class SignupView(APIView):
    def post(self, request):
        # Extract Firebase UID from the request
        firebase_uid = request.data.get("firebase_uid")
        if not firebase_uid:
            return Response(
                {"error": "Firebase UID is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if User.objects.filter(firebase_uid=firebase_uid).exists():
            logger.info(" User Already Exists ")
            return Response(
                {"error": "User already exists. Please log in."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        username = request.data.get("username")
        if not username:
            return Response(
                {"error": "Username is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user_profile = User.objects.create(
                firebase_uid=firebase_uid,
                username=username
            )
            logger.info(f"New user created: {username} (UID: {firebase_uid})")

            return Response(
                {
                    "message": "Signup successful.",
                    "user": {
                        "id": user_profile.id,
                        "firebase_uid": user_profile.firebase_uid,
                        "username": user_profile.username,
                    },
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception as e:
            logger.error(f"Unexpected error during signup: {str(e)}")
            return Response(
                {"error": "An error occurred during signup."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )



class AuthenticationView(BaseAuthentication):
    def authenticate(self, request):
        firebase_uid = request.data.get("firebase_uid")
        print("hello from authentication view")
        if not firebase_uid:
            raise AuthenticationFailed("Firebase UID is required.")

        try:
            user = User.objects.get(firebase_uid=firebase_uid)
            return (user, None) 
        except User.DoesNotExist:
            raise AuthenticationFailed("User does not exist. Please sign up first.")
        except Exception as e:
            raise AuthenticationFailed(f"An unexpected error occurred: {str(e)}")

"""
class AuthenticationView(APIView):
    def post(self, request):
        # Extract Firebase UID from the request
        firebase_uid = request.data.get("firebase_uid")
        if not firebase_uid:
            return Response(
                {"error": "Firebase UID is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Authenticate user based on Firebase UID
        try:
            user_profile = User.objects.get(firebase_uid=firebase_uid)
            logger.info(f"User authenticated: {user_profile.username} (UID: {firebase_uid})")

            return Response(
                {
                    "message": "Authentication successful.",
                    "user": {
                        "id": user_profile.id,
                        "firebase_uid": user_profile.firebase_uid,
                        "username": user_profile.username,
                    },
                },
                status=status.HTTP_200_OK,
            )
        except User.DoesNotExist:
            return Response(
                {"error": "User does not exist. Please sign up first."},
                status=status.HTTP_404_NOT_FOUND,
            )
        except Exception as e:
            logger.error(f"Unexpected error during authentication: {str(e)}")
            return Response(
                {"error": "An error occurred during authentication."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
"""