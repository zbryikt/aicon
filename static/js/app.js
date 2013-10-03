var main;
angular.module('main', []).config(function($httpProvider){
  return $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie('csrftoken');
}).directive('icon', function($compile){
  return {
    restrict: 'E',
    replace: true,
    scope: {
      "src": "@",
      "del": "&",
      "class": "@"
    },
    template: "<div class='svg-icon {{class}}'><div class='object'></div><div class='mask'></div>" + "<div class='delete' ng-click='$event.stopPropagation();del({e: $event})'>" + "<i class='glyphicon glyphicon-minus-sign'></i></div></div>",
    link: function(scope, element, attrs){
      if (!attrs.del) {
        element.find('.delete').remove();
      }
      return attrs.$observe('src', function(v){
        if (v) {
          return element.find('.object').replaceWith("<object class='object' type='image/svg+xml' data='/m/" + v + "'></object>");
        } else {
          return element.find('.object').replaceWith("<div class='object'>no data</div>");
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
  $scope.iconset.del = function(e, s){
    var this$ = this;
    return $http['delete']("/iconset/" + s.pk).success(function(d){
      var that;
      if (that = this$.list.indexOf(s) + 1) {
        return this$.list.splice(that - 1, 1);
      }
    });
  };
  $scope.iconset.cur.add = function(g){
    if (!$scope.iconset.cur.icons.filter(function(it){
      return parseInt(it.pk) === parseInt(g.pk);
    }).length) {
      return $scope.iconset.cur.icons.push(g);
    }
  };
  $scope.iconset.cur.del = function(e, g){
    var that;
    if (that = this.icons.indexOf(g) + 1) {
      return this.icons.splice(that - 1, 1);
    }
  };
  $scope.search = function(){
    console.log($scope.searchKeyword);
    return $http.get('/glyph/', {
      params: {
        q: $scope.searchKeyword
      }
    }).success(function(d){
      return $scope.glyphs = d.data;
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
    var ref$, ref1$;
    if (this.icons.length === 0) {
      return;
    }
    return $http.post('/iconset/', (ref$ = (ref1$ = {}, ref1$.pk = this.pk, ref1$.name = this.name, ref1$), ref$.icons = this.icons.map(function(it){
      return it.pk;
    }), ref$)).success(function(d){
      console.log("save iconset done");
      return $scope.iconset.load();
    });
  };
  $scope.iconset.cur.set = function(s){
    var ref$;
    return (ref$ = $scope.iconset.cur).icons = s.icons, ref$.pk = s.pk, ref$.name = s.name, s;
  };
  $scope.iconset.load = function(){
    return $http.get('/iconset/').success(function(d){
      return $scope.iconset.list = d;
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
      $('#glyph-uploader').modal('hide');
      return $scope.search();
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