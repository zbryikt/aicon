angular.module \main, <[]>
.config ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie \csrftoken
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
  $scope.iconset = {list: [], cur: {}}
  $scope.iconset.cur = icons: [], pk: -1, name: ""
  $scope.search-keyword = ""
  $scope.iconset.del = (e, s) ->
    $http.delete "/iconset/#{s.pk}"
    .success (d) ~> if @list.indexOf(s) + 1 => @list.splice(that - 1, 1)

  $scope.iconset.cur.add = (g) ->
    if !($scope.iconset.cur.icons.filter -> parseInt(it.pk)==parseInt(g.pk)).length => $scope.iconset.cur.icons.push g
  $scope.iconset.cur.del = (e, g) ->
    if @icons.indexOf(g) + 1 => @icons.splice(that - 1, 1)
  $scope.search = ->
    console.log $scope.search-keyword
    $http.get \/glyph/, {params: {q: $scope.search-keyword}}
    .success (d) -> $scope.glyphs = d.data
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
    console.log $(it)val!
    $scope.glyph.new.svg = $(it)val!
    $scope.$apply!
  $scope.glyph.add = ->
    if not $scope.glyph.new.name => return #TODO: check if angular support validation
    if not ( $ \#glyph-uploader-svg .val! ) => return
    $ \#glyph-form-pxy .load ->
      $ \#glyph-uploader .modal \hide
      $scope.search!
    $ \#glyph-form .submit!
    
  $scope.tag.load = ->
    $http.get \/tag/ .success (d) -> $scope.tag.list = d.data

  $scope.lic.load!
  $scope.search!
  $scope.iconset.load!
