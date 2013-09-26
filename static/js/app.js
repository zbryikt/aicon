var main;
angular.module('main', ['ui.select2']).config(function($httpProvider){
  return $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie('csrftoken');
}).directive('icon', function(){
  return {
    restrict: 'E',
    replace: true,
    link: function(scope, element, attrs){
      return attrs.$observe('src', function(v){
        if (v) {
          return element.html("<div class='svg'><object type='image/svg+xml' data='/m/" + v + "'></object><div class='mask'></div></div>");
        } else {
          return element.html("<div></div>");
        }
      });
    }
  };
});
main = function($scope, $http){
  $scope.glyphs = [];
  $scope.tag = {
    list: []
  };
  $scope.lic = {
    name: "",
    desc: "",
    url: "",
    pd: false,
    at: false,
    sa: false,
    nd: false,
    nc: false,
    file: null
  };
  $scope.glyph = {
    'new': {}
  };
  $scope.iconset = {
    list: [],
    cur: {}
  };
  $scope.iconset.cur = {
    icons: [],
    pk: -1,
    name: ""
  };
  $scope.searchKeyword = "";
  $scope.iconset.cur.add = function(g){
    if (!$scope.iconset.cur.icons.filter(function(it){
      return it.pk === g.pk;
    }).length) {
      return $scope.iconset.cur.icons.push(g);
    }
  };
  $scope.search = function(){
    console.log($scope.searchKeyword);
    return $http.get('/glyph/', {
      params: {
        q: $scope.searchKeyword
      }
    }).success(function(d){
      $scope.glyphs = d.data;
      return console.log(d);
    });
  };
  $scope.buildFont = function(){
    return $http.post('/build/', $scope.iconset.cur.icons.map(function(it){
      return it.pk;
    })).success(function(d){
      if (d && d.name) {
        console.log("redirect to /build/" + d.name);
        return window.location.href = "/build/" + d.name;
      } else {
        return console.log("build font failed.");
      }
    });
  };
  $scope.iconset.cur.save = function(){
    var data, ref$;
    data = {};
    ref$ = $scope.iconset.cur, data.pk = ref$.pk, data.name = ref$.name;
    data.icons = $scope.iconset.cur.icons.map(function(it){
      return it.pk;
    });
    console.log(data);
    return $http.post('/iconset/', data).success(function(d){
      return console.log(d, 'done');
    });
  };
  $scope.iconset.cur.set = function(s){
    var ref$;
    console.log('clicked');
    return (ref$ = $scope.iconset.cur).icons = s.icons, ref$.pk = s.pk, ref$.name = s.name, s;
  };
  $scope.iconset.load = function(){
    return $http.get('/iconset/').success(function(d){
      $scope.iconset.list = d;
      return console.log(">>", d);
    });
  };
  $scope.lic.load = function(){
    return $http.get('/license/').success(function(d){
      return $scope.lic.list = d.data;
    });
  };
  $scope.lic.add = function(){
    if (!$scope.lic.name) {
      return;
    }
    $('#lic-form-pxy').load(function(){
      return $('#lic-uploader').modal('hide');
    });
    return $('#lic-form').submit();
  };
  $scope.glyph['new'].setSvg = function(it){
    console.log($(it).val());
    $scope.glyph['new'].svg = $(it).val();
    return $scope.$apply();
  };
  $scope.glyph.add = function(){
    if (!$scope.glyph['new'].name) {
      return;
    }
    if (!$('#glyph-uploader-svg').val()) {
      return;
    }
    $('#glyph-form-pxy').load(function(){
      return $('#glyph-uploader').modal('hide');
    });
    return $('#glyph-form').submit();
  };
  $scope.tag.load = function(){
    return $http.get('/tag/').success(function(d){
      return $scope.tag.list = d.data;
    });
  };
  $scope.lic.load();
  $scope.search();
  return $scope.iconset.load();
};