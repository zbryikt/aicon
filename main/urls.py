from django.conf.urls import patterns, include, url
from django.views.generic import TemplateView
from main import settings, views

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'main.views.home', name='home'),
    # url(r'^main/', include('main.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
    url(r'^$', views.IndexView.as_view()),#TemplateView.as_view(template_name = "index.jade")),
    url(r'^accounts/', include('allauth.urls')),
    url(r'^', include('core.urls')),
    url(r'^test/$', TemplateView.as_view(template_name = 'test.jade')),
)

if settings.DEBUG:
    # static files (images, css, javascript, etc.)
    urlpatterns += patterns('',
        (r'^m/(?P<path>.*)$', 'django.views.static.serve', {
        'document_root': settings.MEDIA_ROOT}))
