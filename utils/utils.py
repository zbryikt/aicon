import json, re
from datetime import datetime
from django.db import models
from django.db.models import Q
from django.core import serializers
from django.http import HttpResponse
from django.views.generic import View
from south.modelsinspector import add_introspection_rules

add_introspection_rules([], ["upn\.utils\.DateTimeField"])

class QueryPager:
  @staticmethod
  def get(args):
    return ( int(args.get("page") or 1), int(args.get("page_limit") or 10), args.get("q") or "")
  @staticmethod
  def fuse(qs, page, limit, wrapper):
    total = len(list(qs))
    qs = qs[(page - 1)*limit:page*limit - 1]
    return HttpResponse('{"hasNext": %s, "data": %s}'%(
      ("true" if (page*limit<total) else "false"),
        wrapper('json', qs)
    ))

class RestView(View):
  des_model = None
  query_attr = ["name"]
  order_by = ""
  wrapper = None
  def serialize(self, type, qs):
    return serializers.serialize(type, qs)
  def get(self, request, *args, **kwargs):
    if "id" in kwargs: return HttpResponse(enjson(self.des_model.objects.filter(pk=kwargs["id"])))
    page, limit, query = QueryPager.get(request.GET)
    print("[%s]"%(str(query)))
    q = Q(name__icontains=query)
    for k in self.query_attr:
      d = {}
      d["%s__icontains"%k] = query
      q = q | Q(**d)
    qs = self.des_model.objects.filter( q ).distinct()
    if self.order_by: qs = qs.order_by(self.order_by)
    wrapper = self.wrapper or self.serialize
    return QueryPager.fuse(qs, page, limit, wrapper)
  def post(self, request, *arg, **kwargs):
    data = request.body
    p = self.des_model.objects.create()
    p.save()
    return HttpResponse(enjson([p]))
  def put(self, request, *args, **kwargs):
    data = request.body
    g = dejson(data)
    for item in g: item.save()
    return HttpResponse(request.body)
  def delete(selef, request):
    pass


class DateTimeField(models.DateTimeField):
  def get_prep_value(self, value):
    try: value = str(datetime.strptime(value, "%Y-%m-%d %H:%M:%S"))
    except: pass
    return value

  def to_python(self, value):
    if isinstance(value, datetime): return value
    value = re.sub("\.\d+Z", "", value)
    value = datetime.strptime(value, "%Y-%m-%dT%H:%M:%S")
    try: value = datetime.strptime(value, "%Y-%m-%dT%H:%M:%S")
    except:
      print("datetime parsing (db -> python) failed. use 'now' instead.")
      value = datetime.now()
    return value

def enjson(obj):
  lst = []
  if ((type(obj)==type([]) and len(filter(lambda x: isinstance(x, models.Model), obj))==len(obj)) or
     isinstance(obj, models.query.QuerySet)): return serializers.serialize('json', obj)
  elif type(obj)==type({}):
    lst = ['"%s": %s'%(k, enjson(obj[k])) for k in obj]
    return "{%s}"%(",".join(lst))
  elif type(obj)==type([]):
    lst = ['%s'%(enjson(k)) for k in obj]
    return "[%s]"%(",".join(lst))
  elif type(obj)==type(1): return obj
  else: return '"%s"'%(obj)

def _dejson(obj):
  if type(obj)==type([]):
    qs = len(obj)>0
    for k in obj:
      if type(k)!=type({}) or not ("pk" in k and "model" in k):
        qs = False
        break
    if qs: obj = serializers.deserialize('json', enjson(obj))
    else:
      for i,k in enumerate(obj):
        obj[i] = _dejson(k)
  if type(obj)==type({}):
    for k in obj:
      obj[k] = _dejson(obj[k])
  return obj

def dejson(data):
  obj = json.loads(data)
  return _dejson(obj)
