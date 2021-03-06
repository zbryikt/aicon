# -*- coding: utf-8 -*-
import datetime, json
from django.db import models
from django.contrib import auth
from taggit.managers import TaggableManager
from utils import utils

class License(models.Model):
  name = models.CharField(max_length = 128)
  desc = models.TextField(default="", blank=True)
  url = models.CharField(max_length = 512, blank=True)
  file = models.FileField(upload_to="license", blank=True, null=True, default=None)
  public_domain = models.BooleanField(default=False)
  attribution = models.BooleanField(default=True)
  sharealike = models.BooleanField(default=False)
  no_derive = models.BooleanField(default=False)
  no_commercial = models.BooleanField(default=False)
  creator = models.ForeignKey(auth.models.User)
  create_date =models.DateTimeField(auto_now_add=True, default=datetime.datetime.now)
  def __unicode__(self):
    return self.name
  wrap_fields = ["name", "desc", "url", "public_domain", "attribution", "sharealike", "no_derice", "no_commercial", "creator", "create_date"]
  @classmethod
  def Wrapper(self, datatype, qs):
    ret = []
    for q in qs:
      obj = {}
      for item in License.wrap_fields:
        obj[item] = getattr(q, item)
      ret += [obj]
    return utils.enjson(ret)

class Glyph(models.Model):
  svg = models.FileField(upload_to="svg")
  name = models.CharField(max_length = 64)
  author = models.CharField(max_length = 128)
  author_url = models.CharField(max_length = 512, blank=True)
  license = models.ForeignKey(License)
  license_url = models.CharField(max_length = 512, blank=True)
  uploader = models.ForeignKey(auth.models.User)
  create_date = models.DateTimeField(auto_now_add=True, default=datetime.datetime.now)
  tags = TaggableManager()

  # TODO let's take time to wrap it as an API
  wrap_fields = ["svg", "name", "author", "author_url", "license", "license_url", "create_date", "uploader","pk"]
  @classmethod
  def Wrapper(self, datatype, qs):
    ret = []
    for q in qs:
      obj = {}
      for item in Glyph.wrap_fields:
        obj[item] = getattr(q, item)
      obj["license"] = {"pk": q.license.pk, "name": q.license.name}
      obj["tags"] = [str(x.name) for x in q.tags.all()]
      ret += [obj]
    return utils.enjson(ret)

class Iconset(models.Model):
  user = models.ForeignKey(auth.models.User)
  name = models.CharField(max_length = 64, default="圖示集")
  create_date = models.DateTimeField(auto_now_add=True, default=datetime.datetime.now)

class Choice(models.Model):
  iconset = models.ForeignKey(Iconset)
  glyph = models.ForeignKey(Glyph)
