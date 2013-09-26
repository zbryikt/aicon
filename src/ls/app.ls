angular.module \main, <[ui.select2]>
.config ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie \csrftoken
.directive \icon, ->
  return {
    restrict: 'E' 
    replace: true
    link: (scope, element, attrs) ->
      attrs.$observe \src, (v) ->
        if v => element.html "<div class='svg'><object type='image/svg+xml' data='/m/#{v}'></object><div class='mask'></div></div>"
        else element.html "<div></div>"
  }

main = ($scope, $http) ->
  $scope.glyphs = []
  $scope.tag = {list: []}
  $scope.lic = {name:"",desc:"",url:"",pd:false,at:false,sa:false,nd:false,nc:false,file:null}
  $scope.glyph = {new: {}}
  $scope.iconset = {list: [], cur: {}}
  $scope.iconset.cur = icons: [], pk: -1, name: ""
  $scope.search-keyword = ""
  $scope.iconset.cur.add = (g) ->
    if !($scope.iconset.cur.icons.filter -> it.pk==g.pk).length => $scope.iconset.cur.icons.push g
  $scope.search = ->
    console.log $scope.search-keyword
    $http.get \/glyph/, {params: {q: $scope.search-keyword}}
    .success (d) ->
      $scope.glyphs = d.data
      console.log d
  $scope.build-font = ->
    $http.post \/build/, ($scope.iconset.cur.icons.map (-> it.pk))
    .success (d) ->
      if d and d.name =>
        console.log "redirect to /build/#{d.name}"
        window.location.href = "/build/#{d.name}"
      else console.log "build font failed."
  $scope.iconset.cur.save = ->
    data = {}
    data{pk, name} = $scope.iconset.cur
    data.icons = ($scope.iconset.cur.icons.map (-> it.pk))
    console.log data
    $http.post \/iconset/, data
    .success (d) ->
      console.log d,\done
  $scope.iconset.cur.set = (s) ->
    console.log \clicked
    $scope.iconset.cur{icons,pk,name} = s
  $scope.iconset.load = ->
    $http.get \/iconset/
    .success (d) ->
      $scope.iconset.list = d
      console.log ">>",d
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
    $ \#glyph-form .submit!
    
  $scope.tag.load = ->
    $http.get \/tag/ .success (d) -> $scope.tag.list = d.data

  $scope.lic.load!
  $scope.search!
  $scope.iconset.load!
