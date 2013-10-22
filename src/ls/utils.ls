utils =
  postify: (g) -> (for k of g => "#{k}=#{g[k]v or g[k]}")join "&"

  svg:
    ns: "http://www.w3.org/2000/svg"
    color: (node, c) ->
      doc = node.contentDocument or node.0.contentDocument
      r = $ doc .find \#svg-clr
      if r.length => return r.css fill: c
      svg = $ doc.querySelectorAll("svg").0
      bk = $ doc.createElementNS @ns, "rect"
        ..attr x: 0 y: 0 width: '102%' height: '201%' style: 'fill:#fff'
      mask = $ doc.createElementNS @ns, "mask"
        ..attr \id, \svg-mask .append bk
      for it in svg.children!
        it.remove!
        mask.append it
      svg.append mask
      svg.append $(doc.createElementNS(@ns, "rect"))attr x: 0 y: 0 width: \100% height: \100% style: "fill:#{c}" id: \svg-clr
      svg.append $(doc.createElementNS(@ns, "rect"))attr x: 0 y: 0 width: \101% height: \101% style: 'fill:#fff;mask:url(#svg-mask)'

