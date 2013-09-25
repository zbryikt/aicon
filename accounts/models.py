# -*- coding: utf-8 -*-
from django.db import models
from django.contrib import auth

from django.utils.translation import ugettext as _
from userena.models import UserenaBaseProfile
from django.db import models

class MainProfile(UserenaBaseProfile):
  user = models.OneToOneField(
    auth.models.User,
    unique=True,
    verbose_name=_('user'),
    related_name='my_profile'
  )

