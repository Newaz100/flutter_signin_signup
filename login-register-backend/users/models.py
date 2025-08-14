from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # You can extend later with phone, avatar, etc.
    pass
