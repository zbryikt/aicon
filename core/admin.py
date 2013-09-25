from django.contrib import admin
#from core.models import *
from core import models
import inspect

# automatically register all classes in core.models
admin.site.register(
  filter(lambda x: x.__module__.startswith("core"),
    map(lambda x: x[1], (inspect.getmembers(models, inspect.isclass)))
))
