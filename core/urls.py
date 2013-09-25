from django.conf.urls import patterns, include, url
from django.views.generic import TemplateView
from core import views

from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^build/$', views.BuildFontView.as_view()),
    url(r'^build/(?P<name>[0-9a-zA-Z]+)/$', views.BuildFontView.as_view()),
    url(r'^glyph/$', views.GlyphView.as_view()),
    url(r'^glyph/(?P<id>\d+)$', views.GlyphView.as_view()),
    url(r'^license/$', views.LicenseView.as_view()),
    url(r'^license/(?P<id>\d+)/$', views.LicenseView.as_view()),
    url(r'^iconset/$', views.IconsetView.as_view()),
    url(r'^iconset/(?P<id>\d+)/$', views.IconsetView.as_view()),
)

