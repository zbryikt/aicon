#!/usr/bin/env python
import fontforge
import glob

def toLigaTuple(v):
  return " ".join(map(lambda x:"C%x"%x,v))

def addLigature(f, c, liga):
  uc, lc = [], []
  for x in liga:
    v = ord(x)
    u = [v,v+32] if v < 97 else [v-32,v]
    uc += [u[0]]
    lc += [u[1]]
  c.addPosSub("lookup1", toLigaTuple(uc))
  c.addPosSub("lookup1", toLigaTuple(lc))
  
f = fontforge.font()
svgs = glob.glob("svgs/*")
for i in xrange(65,122):
  c = f.createChar(i, "C%x"%i)
  c.importOutlines(svgs[0])

count = 0xff01
for svg in svgs:
  c = f.createChar(count, "C%x"%count)
  c.importOutlines(svg)
  count +=1

f.addLookup("lookup", "gsub_ligature", (), (("dlig",(("latn",("dflt")),)),))
f.addLookupSubtable("lookup", "lookup1")

addLigature(f, f["Cff01"], "blah")
addLigature(f, f["Cff02"], "hello")

f.generate("testf.otf")
