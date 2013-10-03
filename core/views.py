from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.views.generic import TemplateView, View
from core import forms
from core.models import Glyph, License, Iconset, Choice
from django.db.models import Q
from main import settings
from utils import utils
from django.core import serializers
from taggit.models import Tag
import fontforge, os, random, glob, zipfile, StringIO, os.path, json

KERNING = 0
tmp_root = "/tmp/aicon"
class BuildFontView(View):
  def get(self, request, *args, **kwargs):
    name = kwargs.get("name") or ""
    fn = os.path.join(tmp_root, name+".zip")
    if not name or not os.path.exists(fn): return redirect("/")
    f = open(fn, "rb")
    data = f.read()
    f.close()
    ret = HttpResponse(data, mimetype="application/zip")
    ret["Content-Disposition"] = "attachment; filename='font.zip'"
    return ret

  def post(self, request, *args, **kwargs):
    try: pk_list = json.loads(request.body)
    except: pk_list = []
    if len(pk_list)<=0: return redirect("/")
    pk = [int(x) for x in pk_list]
    att = []
    f = fontforge.font()
    gs = Glyph.objects.all()
    gs = Glyph.objects.filter(pk__in=pk_list)
    svgs = glob.glob("/Users/kirby/htdocs/testcol/font/don/svgs/*")
    count = 1
    for g in gs:
      if g.license.attribution: att += [g]
      fn = os.path.join(settings.MEDIA_ROOT, str(g.svg))
      if not os.path.exists(fn): continue
      c = f.createChar(0xf000 + count)
      c.importOutlines(fn)
      c.left_side_bearing = KERNING
      c.right_side_bearing = KERNING
      c.simplify()
      c.round()
      count += 1
    random_name = ""
    while True:
      random_name = hex(int(1000000000000*random.random()))
      dir = os.path.join(tmp_root, random_name)
      if not os.path.exists(dir): break
    os.makedirs(dir)
    ttf_fn = os.path.join(dir, "font.ttf")
    eof_fn = os.path.join(dir, "font.eof")
    woff_fn = os.path.join(dir, "font.woff")
    license_fn = os.path.join(dir, "attribution.txt")
    f.generate(ttf_fn)
    f.generate(eof_fn)
    f.generate(woff_fn)
    f = open(license_fn, "w")
    for g in att:
      f.writelines("the icon '%s' is contributed by %s %s\n"%(g.name, g.author, "("+g.author_url+")" if g.author_url else ""))
    f.close()
    files = glob.glob(os.path.join(dir, "*"))
    #buf = StringIO.StringIO()
    zip_fn = os.path.join(tmp_root, random_name+".zip")
    z = zipfile.ZipFile(zip_fn, "w")
    #z = zipfile.ZipFile(buf, "w")
    for f in files:
      b = os.path.basename(f)
      print(b)
      z.write(f, b)
    z.close()
    return HttpResponse(json.dumps({"name": random_name}))
    #return redirect("/build/%s/"%random_name)
    #ret = HttpResponse(buf.getvalue(), mimetype="application/zip")
    #ret["Content-Disposition"] = "attachment; filename='font.zip'"
    #return ret
    #return HttpResponse("")

class GlyphView(utils.RestView):
  des_model = Glyph
  query_attr = ["id", "name", "tags__name"]
  order_by = "-create_date"
  wrapper = Glyph.Wrapper

  def post(self, request, *args, **kwargs):
    print(request.POST)
    form = forms.GlyphForm(request.POST, request.FILES)
    print("Glyph Post")
    if not form.is_valid():    
      print(form)
      context = {"form": form}
      return render(request, 'glyph.jade', context)
    tags = form.cleaned_data["tags"]
    glyph = form.save(commit=False)
    glyph.uploader = request.user
    glyph.save()
    for tag in tags:
      glyph.tags.add(tag)
    return redirect("/")

class Glyph2View(TemplateView):
  def post(self, request, *args, **kwargs):
    form = forms.GlyphForm(request.POST, request.FILES)
    if not form.is_valid():    
      context = {"form": form}
      return render(request, 'glyph.jade', context)
    tags = form.cleaned_data["tags"]
    glyph = form.save(commit=False)
    glyph.uploader = request.user
    glyph.save()
    for tag in tags:
      glyph.tags.add(tag)
    return redirect("/glyph/")

  def get(self, request, *args, **kwargs):
    g = Glyph.objects.all()
    form = forms.GlyphForm()
    context = {"glyphs": g, "form": form}
    return render(request, 'glyph-list.jade', context)
  
class LicenseView(utils.RestView):
  des_model = License
  query_attr = ["id", "name"]
  order_by = "-create_date"

  def post(self, request, *args, **kwargs):
    form = forms.LicenseForm(request.POST, request.FILES)
    if not form.is_valid():    
      context = {"form": form}
      return HttpResponse("[-1]")
    license = form.save(commit=False)
    license.creator = request.user
    license.save()
    return HttpResponse("[0]")

class License2View(TemplateView):
  def post(self, request, *args, **kwargs):
    form = forms.LicenseForm(request.POST, request.FILES)
    if not form.is_valid():    
      context = {"form": form}
      return render(request, 'license-list.jade', context)
    license = form.save(commit=False)
    license.creator = request.user
    license.save()
    return redirect("/")
  def get(self, request, *args, **kwargs):
    g = License.objects.all()
    form = forms.LicenseForm()
    context = {"licenses": g, "form": form}
    return render(request, 'license-list.jade', context)


class IconsetView(utils.RestView):
  des_model = Iconset
  query_attr = ["id", "name", "user__username"]
  order_by = "-create_date"

  def delete(self, request, *args, **kwargs):
    try: 
      id = int(kwargs["id"])
      iconset = Iconset.objects.get(pk=id)
      iconset.delete()
    except: raise Http404()
    return HttpResponse("[0]")

  def get(self, request, *args, **kwargs):
    try: id = int(kwargs.get("id")) or -1
    except: id = 0
    try: iconset = [Iconset.objects.get(pk=id)]
    except: iconset = Iconset.objects.filter(user=request.user)
    ret = []
    for s in iconset:
      obj = {"name": s.name, "pk": s.pk, "icons": [], "cover": "svg/default.svg"}
      choices = Choice.objects.filter(iconset__pk=s.pk)
      obj["icons"] = [{"pk": x.glyph.pk, "name": x.glyph.name, "svg": str(x.glyph.svg)} for x in choices]
      if len(choices)>0: obj["cover"] = str(choices[0].glyph.svg)
      ret += [obj]
    return HttpResponse(json.dumps(ret))

  def post(self, request, *args, **kwargs):
    try: data = json.loads(request.body)
    except: data = {"icons": [], "name": "", "pk": -1}
    d_gs = {}
    data["icons"] = [int(x) for x in data["icons"]]
    gs = Glyph.objects.filter(pk__in=data["icons"])
    for g in gs: d_gs[g.pk] = g
    k_gs = d_gs.keys()
    data["icons"] = filter(lambda x: x in k_gs, data["icons"])
    if len(data.get("icons") or [])==0: return HttpResponse("[]")
    print("pk: %d"%data.get("pk"))
    try: iconset = Iconset.objects.get(pk=(data.get("pk") or -1))
    except: iconset = Iconset.objects.create(user=request.user)
    if data.get("name"): iconset.name = data["name"]
    iconset.save()
    for gpk in data["icons"]:
      c = Choice.objects.filter(Q(glyph__pk=gpk) & Q(iconset=iconset))
      if len(c): continue
      c = Choice.objects.create(glyph=d_gs[gpk], iconset=iconset)
      c.save()
    return HttpResponse('["ok"]')

class TagView(utils.RestView):
  des_model = Tag
  query_attr = ["name"]
