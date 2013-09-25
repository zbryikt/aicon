import re
from django import template

register = template.Library()

@register.filter
def svg_name(name):
  result = re.search(r".+/(.+)\.svg", str(name))
  if not result: return name
  return result.group(1)
