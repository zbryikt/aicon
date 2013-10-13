angular.module \main, <[ui.select2]>
.config ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie \csrftoken
.directive \tags ($compile) ->
  return 
    restrict: 'E'
    replace: true
    scope: {"model": '=ngModel', name: '@'}
    template: "<input type='hidden' class='tags'>"
    link: (scope, element, attrs) ->
      $ element .select2 do
        tokenSeparators: [",", " "]
        multiple: true
        data: []
        createSearchChoice: (term,data) ->
          if data.filter(-> (it.text.locale-compare term)==0).length==0 => return {id:term, text:term}
      .on \change (e) -> scope.$apply -> scope.model = $ element .select2 \data
      scope.$watch \model (v) -> $ element .select2 \data,  v

.directive \license ($compile) ->
  return 
    restrict: 'E'
    replace: true
    scope: {"model": '=ngModel', name: '@'}
    template: "<input type='hidden'>"
    link: (scope, element, attrs) ->
      element .select2 do
        placeholder: "choose a license"
        minimumInputLength: 0
        ajax: do
          url: \/license/
          type: \GET
          dataType: \json
          quiteMillis: 100
          data: (term, page) -> q: term, page_limit: 10, page: page
          results: (d, p) -> results: d.data, more: d.hasNext
        initSelection: ->
        formatResult: -> (it.fields and "<div>#{it.pk}. #{it.fields and it.fields['name']}</div>") or ""
        formatSelection: -> (it.fields and "<div>#{it.pk}. #{it.fields['name']}</div>") or ""
        formatNoMatches: -> \找不到這個項目
        formatSearching: -> \搜尋中
        formatInputTooShort: -> \請多打幾個字
        id: (e) -> e.fields and "#{e.pk}" or ""
        escapeMarkup: -> it
      .on \change (e) -> scope.$apply -> scope.model = $ element .select2 \data
      scope.$watch \model (v) -> $ element .select2 \data,  v
      
.directive \icon, ($compile)->
  return
    restrict: 'E' 
    replace: true
    scope: {"src": "@", "del": "&", "class": "@"}
    template:
      "<div class='svg-icon {{class}}'><div class='object'></div><div class='mask'></div>" + 
      "<div class='delete' ng-click='$event.stopPropagation();del({e: $event})'>" +
      "<i class='glyphicon glyphicon-minus-sign'></i></div></div>"
    link: (scope, element, attrs) ->
      if !attrs.del => element.find \.delete .remove!
      attrs.$observe \src, (v) ->
        if v => element.find \.object .replaceWith "<object class='object' type='image/svg+xml' data='/m/#{v}'></object>"
        else element.find \.object .replaceWith "<div class='object'>no data</div>"

main = ($scope, $http) ->
  $scope.glyphs = []
  $scope.tag = {list: []}
  $scope.lic = {name:"",desc:"",url:"",pd:false,at:false,sa:false,nd:false,nc:false,file:null}
  $scope.iconset = {list: [], cur: {}, detail: true}
  $scope.iconset.cur = icons: [], pk: -1, name: ""
  $scope.search-keyword = ""
  $scope.detail = {}
  $scope.mouse = {select: false}
  $scope.mouse.over = (e, g) ->
    console.log "moving: #{g.name}"
    if @select => g.added = !g.added

  $scope.search-timer = null
  $scope.$watch \searchKeyword, ->
    if $scope.search-timer => clearTimeout $scope.search-timer
    $scope.search-timer = setTimeout (-> $scope.search!), 700

  $scope.detail.show = (e, s) ->
    @cur = s
    console.log s.tags, s.license
    e.stopPropagation!
    $ \#glyph-detail .modal \show

  $scope.iconset.del = (e, s) ->
    $http.delete "/iconset/#{s.pk}"
    .success (d) ~> if @list.indexOf(s) + 1 => @list.splice(that - 1, 1)

  $scope.iconset.cur.add = (g) ->
    if !(@icons.filter -> parseInt(it.pk)==parseInt(g.pk)).length =>
      g.added = true
      @icons.push g
    else
      @icons.splice @icons.indexOf(g), 1
      g.added = false
  $scope.iconset.cur.del = (e, g) ->
    if @icons.indexOf(g) + 1 => @icons.splice(that - 1, 1)
  $scope.search = ->
    console.log "searching: ",$scope.search-keyword
    $http.get \/glyph/, {params: {q: $scope.search-keyword, page_limit: 100}}
    .success (d) -> 
      console.log "load glyphs.."
      $scope.glyphs = d.data
  $scope.build-font = ->
    $http.post \/build/, ($scope.iconset.cur.icons.map (-> it.pk))
    .success (d) ->
      if d and d.name =>
        console.log "redirect to /build/#{d.name}"
        window.location.href = "/build/#{d.name}"
      else console.log "build font failed."
  $scope.iconset.cur.save = ->
    if @icons.length==0 => return
    $http.post \/iconset/, {} <<< @{pk,name} <<< {icons: @icons.map ->it.pk }
    .success (d) -> 
      console.log "save iconset done"
      $scope.iconset.load!
  $scope.iconset.cur.set = (s) ->
    $scope.iconset.cur{icons,pk,name} = s
  $scope.iconset.load = ->
    $http.get \/iconset/
    .success (d) ->
      $scope.iconset.list = d
  $scope.lic.load = ->
    $http.get \/license/
    .success (d) -> $scope.lic.list = d.data
  $scope.lic.add = ->
    if not $scope.lic.name => return #TODO: check if angular support validation
    $ \#lic-form-pxy .load ->
      $ \#lic-uploader .modal \hide
      #console.log ( $ \#lic-form-pxy .contents!0.body.innerText )
    $ \#lic-form .submit!


  $scope.tag.load = ->
    $http.get \/tag/ .success (d) -> $scope.tag.list = d.data

  ########## for uploading glyph #########
  $scope.glyph = 
    # handler after uploading glyph
    h:
      init: ->
        $ \#glyph-new-form-pxy .load ~> @proxy!
        @init = ->
      proxy: -> @main!
      main: null
      set: -> 
        @init!
        @main = it

    # short-cut for glyph.item
    n: null 
    init: ->
      @list.data = []
      @n = @item.data = $.extend true, {}, {} <<< @init-data
      $ \#glyph-new-modal .modal \show
        ..find \.single .show!
        ..find \.multiple .hide!
    list:
      data: []
      save: ->
        len = 0
        console.log "todo: some how multi-editing form checking is not working. please check"
        for d in @data
          len += (for k of d{name,author,license,tags} =>
            #!d[k].p = if !d[k].v => false else true
          )filter(->it).length
        if len>0 => return
        $scope.glyph.h.set @callback
        $ \#glyph-new-form .submit!
      callback: ->
        pks = JSON.parse($ \#glyph-new-form-pxy .contents!find \body .html!)
        console.log "pks: ",pks
        if pks.length == $scope.glyph.list.data.length =>
          $ \#glyph-new-modal .modal \hide
          return $scope.search!
        else $ '#glyph-new-modal .error-hint.missed' .show!delay 2000 .fadeOut 1000
        #ret = []
        #for it in $scope.new.list.data
        #  if !(it.id in pks) => ret.push it
        #$scope.$apply -> $scope.glyph.list.data = ret
        $scope.$apply ~> $scope.glyph.list.data = $scope.glyph.list.data.filter -> !(it.id in pks)
    item:
      data: {}
      save: ->
        if (for k of @data{name,author,license,tags} =>
          !@data[k].p = if !@data[k].v => false else true
        )filter(->it).length>0 => return
        if not ( $ \#glyph-new-svg .val! ) => return @data.svg.p = false
        $scope.glyph.h.set @callback
        $ \#glyph-new-form .submit!
      callback: ->
        pks = JSON.parse($ \#glyph-new-form-pxy .contents!find \body .html!)
        if pks.length==0 => return $ '#glyph-new-modal .error-hint.error' .show!delay 2000 .fadeOut 1000
        f = document.getElementById \glyph-new-svg .files
        if f.length==1
          $ \#glyph-new-modal .modal \hide
          return $scope.search!
        # for working in main frame
        angular.element \#glyph-new-modal .scope!$apply ->
          $scope.glyph.list.data = for x,i in f =>
            $.extend true, {}, {id: pks[i], svg: "svg/#{x.name}"} <<< $scope.glyph.item.data{name,author,author_url,license,tags}
        $ "\#glyph-new-modal .multiple" .show!
        $ "\#glyph-new-modal .single" .hide!
    init-data:
      # p: check passed / v: value
      name:       { p: true, v: "" }
      author:     { p: true, v: "" }
      author_url: { p: true, v: "" }
      license:    { p: true, v: "" }
      tags:       { p: true, v: "" }
      svg:        
        p: true
        v: "(no file selected)"
        set: (v) -> $scope.$apply ~> 
          f = [x.name for x in document.getElementById \glyph-new-svg .files]
          @v = if f.length > 1 => "#{f.0}\n... (#{f.length} files)"
               else if f.length==1 => "#{f.0}"
               else "(no file selected)"

  $scope.lic.load!
  $scope.iconset.load!
