angular.module \main, <[]>
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
  $scope.iconset.load = ->
    $http.get \/iconset/
    .success (d) ->
      $scope.iconset.list = d
      console.log ">>",d

  $scope.search!
  $scope.iconset.load!
