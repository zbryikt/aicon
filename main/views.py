from django.views.generic import View
from django.shortcuts import render, redirect
from core import forms

class IndexView(View):
  def get(self, request, *args, **kwargs):
    glyph_form = forms.GlyphForm()
    license_form = forms.LicenseForm()
    context = {"glyph_form": glyph_form, "license_form": license_form}
    return render(request, 'index.jade', context)
