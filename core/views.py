from django.shortcuts import render, redirect
from django.http import HttpResponse, Http404
from django.views.generic import TemplateView, View
from core import forms
from core.models import Glyph, License, Iconset, Choice
from django.db.models import Q
from main import settings
from utils import utils
from django.core import serializers
from taggit.models import Tag
from django.forms.formsets import formset_factory
import fontforge, os, random, glob, zipfile, StringIO, os.path, json, re

KERNING = 0
tmp_root = "/tmp/aicon"

def make_preview(fcss, fhtml, cm):
  names = {}
  fhtml.writelines(
"""<!DOCTYPE html><html><head><link rel="stylesheet" type="text/css" href="font.css"><style type="text/css">
body{background:#eee;font-family:arial}
.ib{text-align:center;display:inline-block;padding:10px 10px 5px;margin:5px;width:160px;border:1px solid #444;
border-radius:3px;background:#fff;box-shadow:1px 1px 3px rgba(0,0,0,0.1)}
.ib>div{display:inline-block;padding:5px;font-size:16px;border-bottom:1px solid #999;width:90%}
.ib>div:last-of-type{font-size:64px;border-bottom:none;text-shadow:1px 1px 3px rgba(0,0,0,0.2)
}</style></head><body><h3>myfont preview</h3>""")
  fcss.writelines("""
@font-face{font-family:myfont;src:url('font.ttf')}
i.icon{font-style:normal;font-family:myfont;vertical-align:baseline}
i.icon:after{display:inline}
  """)
  fhtml.writelines("<div class='ib' style='background:#bbb;color:#fff'><div>class name</div><div>16px preview</div><div>64px</div></div>")
  for item in cm:
    key = item + 0xf000
    name = re.sub(r"[^a-zA-Z0-9-]", "-", cm[item].name)
    names.setdefault(name, 0)
    names[name]+=1
    c = names[name]
    name = name + (("_%d"%c) if c>1 else "")
    fcss.writelines('i.icon.%s:after { content: "\\%4x" }\n'%(name, key))
    fhtml.writelines(
      "<div class='ib'><div>%s</div>"%(name) + 
      "<div>align <i class='icon %s'></i> preview</div>"%(name) + 
      "<div><i class='icon %s'></i></div></div>"%(name)
    )
  fhtml.writelines("</body></html>")
  fhtml.close()
  fcss.close()

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
    print(request.body)
    print(pk_list)
    if len(pk_list)<=0: return redirect("/")
    pk = [int(x) for x in pk_list]
    att = []
    codemap = {}
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
      codemap[count] = g
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
    css_fn = os.path.join(dir, "font.css")
    html_fn = os.path.join(dir, "font.html")
    f.generate(ttf_fn)
    f.generate(eof_fn)
    f.generate(woff_fn)
    f = open(license_fn, "w")
    for g in att:
      f.writelines("the icon '%s' is contributed by %s %s\n"%(g.name, g.author, "("+g.author_url+")" if g.author_url else ""))
    f.close()
    fcss = open(css_fn, "w")
    fhtml = open(html_fn, "w")
    make_preview(fcss, fhtml, codemap)
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

  def put(self, request, *args, **kwargs):
    try: 
      id = int(kwargs["id"])
      g = Glyph.objects.get(pk=id)
      if request.user!=g.uploader: raise
      data = utils.dejson(request.body)
      form = forms.GlyphEditForm(data, instance=g)
      if not form.is_valid(): 
        print(form.errors)
        print("not valid")
        return HttpResponse("[]")
      form.save()
    except: raise Http404()
    return HttpResponse("[%d]"%id)
 
  def post(self, request, *args, **kwargs):
    if 'form-0-name' in request.POST:
      GFS = formset_factory(forms.GlyphEditForm)
      formset = GFS(request.POST, request.FILES)
      count,finished = 0, []
      for form in formset:
        if not form.is_valid(): continue
        try:
          pk = int(request.POST["form-%d-id"%count])
          glyph = Glyph.objects.get(pk=pk)
        except: continue
        glyph.name = form.cleaned_data["name"]
        glyph.author = form.cleaned_data["author"]
        glyph.author_url = form.cleaned_data["author_url"]
        glyph.license = form.cleaned_data["license"]
        glyph.color = form.cleaned_data["color"]
        glyph.rotation = form.cleaned_data["rotation"]
        glyph.animation = form.cleaned_data["animation"]
        glyph.ligature = form.cleaned_data["ligature"]

        for tag in form.cleaned_data["tags"]:
          glyph.tags.add(tag)
        glyph.save()
        count+=1
        finished += [pk]
      return HttpResponse(utils.enjson(finished))

    filelist =  request.FILES.getlist("svg")
    pks = []
    for item in filelist:
      f = {"svg": item}
      form = forms.GlyphForm(request.POST, f)
      if not form.is_valid():    
        context = {"form": form}
        return HttpResponse(utils.enjson([]))
      tags = form.cleaned_data["tags"]
      glyph = form.save(commit=False)
      glyph.uploader = request.user
      glyph.save()
      pks += [glyph.pk]
      for tag in tags:
        glyph.tags.add(tag)

    return HttpResponse(utils.enjson(pks))

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

  def put(self, request, *args, **kwargs):
    try: data = utils.dejson(request.body)
    except: return HttpResponse("[]")
    lic = License.objects.filter(pk__in=data)
    return HttpResponse(utils.enjson(lic))

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
    if not request.user.is_authenticated(): return HttpResponse([])
    try: 
      id = int(kwargs["id"])
      iconset = Iconset.objects.get(pk=id)
      iconset.delete()
    except: raise Http404()
    return HttpResponse("[0]")

  def get(self, request, *args, **kwargs):
    if not request.user.is_authenticated(): return HttpResponse(json.dumps([]))
    try: id = int(kwargs.get("id")) or -1
    except: id = 0
    try: iconset = [Iconset.objects.get(pk=id)]
    except: iconset = Iconset.objects.filter(user=request.user)
    ret = []
    for s in iconset:
      obj = {"name": s.name, "desc": s.desc, "perm": s.perm, "permkey": s.permkey, "pk": s.pk, "icons": [], "cover": "svg/default.svg"}
      glyphs = [x.glyph for x in Choice.objects.filter(iconset__pk=s.pk)]
      obj["icons"] = glyphs # Glyph.Wrapper('json', glyphs)
      #obj["icons"] = [{"pk": x.glyph.pk, "name": x.glyph.name, "svg": str(x.svg)} for x in glyphs]
      if len(glyphs)>0: obj["cover"] = str(glyphs[0].svg)
      ret += [obj]
    return HttpResponse(utils.enjson(ret)) #json.dumps(ret))

  def post(self, request, *args, **kwargs):
    if not request.user.is_authenticated(): return HttpResponse("[]")
    try: data = json.loads(request.body)
    except: data = {"icons": [], "name": "", "pk": -1}
    d_gs = {}
    data["icons"] = [int(x) for x in data["icons"]]
    gs = Glyph.objects.filter(pk__in=data["icons"])
    for g in gs: d_gs[g.pk] = g
    k_gs = d_gs.keys()
    data["icons"] = filter(lambda x: x in k_gs, data["icons"])
    print(len(data.get("icons") or[]))
    if len(data.get("icons") or [])==0: return HttpResponse("[]")
    print("pk: %d"%data.get("pk"))
    try: iconset = Iconset.objects.get(pk=(data.get("pk") or -1))
    except: iconset = Iconset.objects.create(user=request.user)
    if data.get("name"): iconset.name = data["name"]
    if data.get("desc"): iconset.desc = data["desc"]
    if data.get("perm"): iconset.perm = int(data["perm"])
    if data.get("permkey"): iconset.permkey = data["permkey"]
    iconset.save()
    data["pk"] = iconset.pk
    for gpk in data["icons"]:
      c = Choice.objects.filter(Q(glyph__pk=gpk) & Q(iconset=iconset))
      if len(c): continue
      c = Choice.objects.create(glyph=d_gs[gpk], iconset=iconset)
      c.save()
    # todo: remove
    cs = Choice.objects.filter(Q(iconset=iconset))
    for c in cs:
      if not (c.glyph.pk in data["icons"]): c.delete()
    return HttpResponse(utils.enjson(data))

class TagView(utils.RestView):
  des_model = Tag
  query_attr = ["name"]
