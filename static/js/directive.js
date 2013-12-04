// Generated by LiveScript 1.2.0
angular.module('utils', []).directive('tags', function($compile){
  return {
    restrict: 'E',
    replace: true,
    scope: {
      "model": '=ngModel',
      name: '@'
    },
    template: "<input type='hidden' class='tags' placeholder='add tags...'>",
    link: function(scope, element, attrs){
      $(element).select2({
        tokenSeparators: [",", " "],
        multiple: true,
        data: [],
        createSearchChoice: function(term, data){
          if (data.filter(function(it){
            return it.text.localeCompare(term) === 0;
          }).length === 0) {
            return {
              id: term,
              text: term
            };
          }
        }
      }).on('change', function(e){
        return scope.$apply(function(){
          return scope.model = $(element).select2('data');
        });
      });
      return scope.$watch('model', function(v){
        return $(element).select2('data', v);
      });
    }
  };
}).directive('license', function($compile){
  return {
    restrict: 'E',
    replace: true,
    scope: {
      "model": '=ngModel',
      name: '@'
    },
    template: "<input type='hidden'>",
    link: function(scope, element, attrs){
      element.select2({
        placeholder: "choose a license",
        minimumInputLength: 0,
        ajax: {
          url: '/license/',
          type: 'GET',
          dataType: 'json',
          quiteMillis: 100,
          data: function(term, page){
            return {
              q: term,
              page_limit: 10,
              page: page
            };
          },
          results: function(d, p){
            return {
              results: d.data,
              more: d.hasNext
            };
          }
        },
        initSelection: function(){},
        formatResult: function(it){
          return (it.fields && "<div>" + it.pk + ". " + (it.fields && it.fields['name']) + "</div>") || "";
        },
        formatSelection: function(it){
          return (it.fields && "<div>" + it.pk + ". " + it.fields['name'] + "</div>") || "";
        },
        formatNoMatches: function(){
          return '找不到這個項目';
        },
        formatSearching: function(){
          return '搜尋中';
        },
        formatInputTooShort: function(){
          return '請多打幾個字';
        },
        id: function(e){
          return e.fields && e.pk + "" || "";
        },
        escapeMarkup: function(it){
          return it;
        }
      }).on('change', function(e){
        return scope.$apply(function(){
          return scope.model = $(element).select2('data');
        });
      });
      return scope.$watch('model', function(v){
        return $(element).select2('data', v);
      });
    }
  };
}).directive('icon', function($compile){
  return {
    restrict: 'E',
    replace: true,
    scope: {
      "src": "@",
      "del": "&",
      "class": "@",
      "color": "@",
      "animate": "@",
      "rotate": "@"
    },
    template: "<div class='svg-icon {{class}} {{animate}}'><div class='object'></div><div class='mask'></div>" + "<div class='delete' ng-click='$event.stopPropagation();del({e: $event})'>" + "<i class='icon remove'></i></div></div>",
    link: function(scope, element, attrs){
      if (!attrs.del) {
        element.find('.delete').remove();
      }
      if (attrs.ngMouseover) {
        element.on('mouseover', function(e){
          var x$;
          x$ = scope.$parent;
          x$.$event = e;
          x$.$apply(attrs.ngMouseover);
          return x$;
        });
      }
      if (attrs.ngMouseout) {
        element.on('mouseout', function(e){
          var x$;
          x$ = scope.$parent;
          x$.$event = e;
          x$.$apply(attrs.ngMouseout);
          return x$;
        });
      }
      if (attrs.ngClick) {
        element.on('click', function(e){
          var x$;
          x$ = scope.$parent;
          x$.$event = e;
          x$.$apply(attrs.ngClick);
          return x$;
        });
      }
      attrs.$observe('rotate', function(v){
        return element.css('-webkit-transform', "rotate(" + (v || 0) + "deg)");
      });
      attrs.$observe('color', function(v){
        var that;
        if (that = element.find('iframe')[0]) {
          return $(that.contentDocument).find("*").css('fill', attrs.color || '#000');
        }
      });
      attrs.$observe('animate', function(v){
        var that;
        console.log("rotation: ", v);
        if (that = scope.oldAnimation) {
          element.removeClass(that);
        }
        if (v) {
          element.addClass(v = v.toLowerCase());
        }
        return scope.oldAnimation = v;
      });
      return attrs.$observe('src', function(v){
        var node;
        if (v) {
          if (attrs.color) {
            node = $("<iframe class='object' src='/m/" + v + "'></iframe>");
            element.find('.object').replaceWith(node);
            return node.load(function(){
              return $(node[0].contentDocument).find("*").css('fill', attrs.color || '#0f0');
            });
          } else {
            return element.find('.object').replaceWith("<img class='object' src='/m/" + v + "'>");
          }
        } else {
          return element.find('.object').replaceWith("<div class='object'>no data</div>");
        }
      });
    }
  };
});