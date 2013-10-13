from django import forms
from core.models import Glyph, License

class GlyphForm(forms.ModelForm):
  class Meta:
    model = Glyph
    fields = ["svg", "name", "author", "license", "author_url", "license_url", "tags"]

class GlyphEditForm(forms.ModelForm):
  class Meta:
    model = Glyph
    fields = ["name", "author", "license", "author_url", "license_url", "tags"]

class LicenseForm(forms.ModelForm):
  class Meta:
    model = License
    fields = ["name", "desc", "url", "public_domain", "attribution", "sharealike", "no_derive", "no_commercial", "file"]

