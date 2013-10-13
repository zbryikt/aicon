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
      scope.$watch \model (v) -> if v => $ element .select2 \data,  v

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
      scope.$watch \model (v) -> if v => $ element .select2 \data,  v
      
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
  $scope.glyph = {new: {}}
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
  $scope.glyph.new.set-svg = ->
    # check if it has multiple files: document.getElementById \glyph-uploader-svg .files
    $scope.glyph.new.svg = $(it)val!
    $scope.$apply!
  glyph-form-handler = null
  glyph-form-handler-step1 = ->
    console.log "step1..."
    pks = JSON.parse($ \#glyph-form-pxy .contents!find \body .html!)
    console.log "pks: ",pks
    f = document.getElementById \glyph-uploader-svg .files
    if f.length==1
      $ \#glyph-uploader .modal \hide
      return $scope.search!
    # for working in main frame
    angular.element \#glyph-uploader .scope!$apply ->
      $scope.new-files.data = for x,i in f =>
        id: pks[i]
        svg: "svg/#{x.name}"
        name: $scope.glyph.new.name
        author: $scope.glyph.new.author
        author_url: $scope.glyph.new.author_url
        license: $scope.glyph.new.license
        tags: $scope.glyph.new.tags
    $ "\#glyph-uploader .multiple" .show!
    $ "\#glyph-uploader .single" .hide!

  glyph-form-handler-step2 = ->
    console.log "multi edit submiited"
    pks = JSON.parse($ \#glyph-form-pxy .contents!find \body .html!)
    console.log "saved pk: ",pks
    if pks.length == $scope.new-files.data.length =>
      $ \#glyph-uploader .modal \hide
      return $scope.search!
    console.log $scope.new-files.data
    ret = []
    for it in $scope.new-files.data
      if !(it.id in pks) => ret.push it
    $scope.new-files.data = ret
    console.log $scope.new-files.data
    $scope.$apply!

  $scope.new-files = 
    data: []
    save: ->
      console.log "todo"
      #TODO: do form validation
      glyph-form-handler := glyph-form-handler-step2
      $ \#glyph-form-pxy .load -> glyph-form-handler!
      $ \#glyph-form .submit!

  $scope.glyph.add = ->
    console.log \adding...
    if not $scope.glyph.new.name => return #TODO: check if angular support validation
    if not ( $ \#glyph-uploader-svg .val! ) => return
    glyph-form-handler := glyph-form-handler-step1
    $ \#glyph-form-pxy .load -> glyph-form-handler!

    $ \#glyph-form .submit!
    
  $scope.tag.load = ->
    $http.get \/tag/ .success (d) -> $scope.tag.list = d.data
  $scope.glyph-upload = {}
  $scope.glyph-upload.show = ->
    $ \#glyph-uploader .modal \show
    # revert them for development
    #$scope.new-files = ["svg/rate-bad.svg", "svg/rate-good.svg","svg/state-error.svg","svg/state-warning.svg"]
    #$ "\#glyph-uploader .single" .hide!
    #$ "\#glyph-uploader .multiple" .show!
    $ "\#glyph-uploader .single" .show!
    $ "\#glyph-uploader .multiple" .hide!
    

  $scope.lic.load!
  $scope.iconset.load!
