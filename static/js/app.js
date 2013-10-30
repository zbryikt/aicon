// Generated by LiveScript 1.2.0
var main;
angular.module('main', ['ui.select2', 'utils']).config(function($httpProvider){
  $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie('csrftoken');
  return $.fn.modal.settings.selector.close = "-nop-";
});
if (deepEq$(typeof String.prototype.trim, "undefined", '===')) {
  String.prototype.trim = function(){
    return String(this).replace(/^\s+|\s+$/g, '');
  };
}
main = function($scope, $http){
  $scope = import$($scope, {
    buildFont: function(){
      $scope.st.save();
      console.log("building: " + $scope.st.cur.icons.map(function(it){
        return it.pk;
      }));
      return $http.post('/build/', $scope.st.cur.icons.map(function(it){
        return it.pk;
      })).success(function(d){
        if (d && d.name) {
          console.log("redirect to /build/" + d.name);
          return window.location.href = "/build/" + d.name;
        } else {
          return console.log("build font failed.");
        }
      });
    },
    ui: {
      detail: true
    },
    st: {
      sets: [],
      init: function(){
        var this$ = this;
        return $http.get('/iconset/').success(function(d){
          this$.sets = d;
          return this$.chk();
        });
      },
      len: 0,
      name: "圖示集",
      list: {},
      show: false,
      cur: {
        icons: [],
        name: "圖示集",
        pk: -1
      },
      chk: function(rmed){
        rmed == null && (rmed = null);
        if (!this.sets.length) {
          this['new']();
        }
        if (!rmed || rmed === this.cur) {
          return this.load(this.sets[0]);
        }
      },
      rmset: function(e, s){
        var that, this$ = this;
        if (s && s.pk >= 0) {
          return $http['delete']("/iconset/" + s.pk).success(function(d){
            var that;
            if (that = this$.sets.indexOf(s) + 1) {
              this$.sets.splice(that - 1, 1);
            }
            return this$.chk(s);
          });
        } else if (that = this.sets.indexOf(s) + 1) {
          this.sets.splice(that - 1, 1);
          return this.chk(s);
        }
      },
      toggle: function(){
        this.show = !this.show;
        if (this.show) {
          return $(".ico-li.iconset .ib").show();
        } else {
          return $(".ico-li.iconset .ib").hide();
        }
      },
      add: function(g){
        var that, ref$, key$, ref1$;
        if (that = g.added = this.list[g.pk]
          ? this.len-- && (ref1$ = (ref$ = this.list)[key$ = g.pk], delete ref$[key$], ref1$) && false
          : (this.list[g.pk] = g) && true) {
          this.len++ && that;
        }
        return this.saveBuf();
      },
      clean: function(){
        var k, this$ = this;
        return (function(){
          var results$ = [];
          for (k in this.list) {
            results$.push(k);
          }
          return results$;
        }.call(this)).map(function(it){
          this$.list[it].added = false;
          delete this$.list[it];
          return this$.len--;
        });
      },
      randName: function(){
        var ref$;
        return (ref$ = ['圖示集', '我的集合', '尚未命名', '還沒取名', '新集合', '超棒列表'])[parseInt(Math.random() * ref$.length)];
      },
      newCount: 0,
      'new': function(){
        return this.sets.push(this.load({
          cover: "default/unknown.svg",
          icons: [],
          name: this.randName(),
          pk: --this.newCount
        }));
      },
      load: function(s){
        var this$ = this;
        this.save();
        this.clean();
        this.cur = s;
        this.name = s.name;
        s.icons.map(function(it){
          return this$.add($scope.gh.item(it.pk, it));
        });
        return s;
      },
      saveTimer: null,
      saveBuf: function(){
        var this$ = this;
        if (this.saveTimer) {
          clearTimeout(this.saveTimer);
        }
        return this.saveTimer = setTimeout(function(){
          this$.saveTimer = null;
          return this$.save();
        }, 5000);
      },
      save: function(){
        var ref$, ref1$, k, des, this$ = this;
        if (this.saveTimer) {
          clearTimeout(this.saveTimer);
          this.saveTimer = null;
        }
        if (!this.len) {
          return;
        }
        ref1$ = {
          name: this.name,
          icons: []
        }, (ref$ = this.cur).name = ref1$.name, ref$.icons = ref1$.icons;
        (function(){
          var results$ = [];
          for (k in this.list) {
            results$.push(k);
          }
          return results$;
        }.call(this)).map(function(it){
          return this$.cur.icons.push(this$.list[it]);
        });
        des = this.cur;
        return $http.post('/iconset/', {
          pk: this.cur.pk,
          name: this.name,
          icons: (function(){
            var results$ = [];
            for (k in this.list) {
              results$.push(k);
            }
            return results$;
          }.call(this)).map(function(it){
            return this$.list[it].pk;
          })
        }).success(function(d){
          if (des.pk === -1) {
            return des.pk = d.pk;
          }
        });
      }
    },
    qr: {
      keyword: "",
      timer: null,
      init: function(){
        var this$ = this;
        return $scope.$watch('query.keyword', function(){
          if (this$.timer) {
            clearTimeout(this$.timer);
          }
          return this$.timer = setTimeout(function(){
            return this$.load();
          }, 700);
        });
      },
      load: function(){
        return $http.get('/glyph/', {
          params: {
            q: this.keyword,
            page_limit: 100
          }
        }).success(function(d){
          var ref$, hash, k;
          ref$ = [[], {}], $scope.gh.list = ref$[0], hash = ref$[1];
          d.data.map(function(it){
            return $scope.gh.list.push($scope.gh.item(it.pk, it));
          });
          d.data.map(function(it){
            return hash[it.license.pk] = 1;
          });
          return $scope.lc.fetch((function(){
            var results$ = [];
            for (k in hash) {
              results$.push(k);
            }
            return results$;
          }()));
        });
      }
    },
    lc: {
      hash: {},
      item: function(k, v){
        if (v && !(k in this.hash)) {
          return this.hash[k] = v;
        } else {
          return this.hash[k];
        }
      },
      load: function(){
        var this$ = this;
        return $http.get('/license/').success(function(d){
          return d.data.map(function(it){
            return this$.item(it.pk, it);
          });
        });
      },
      fetch: function(v){
        var this$ = this;
        if (!v) {
          return $.ajax('/license/', {
            dataType: 'json'
          }).success(function(d){
            var i$, ref$, len$, it, results$ = [];
            for (i$ = 0, len$ = (ref$ = d.data).length; i$ < len$; ++i$) {
              it = ref$[i$];
              results$.push(this$.item(it.pk, it));
            }
            return results$;
          });
        }
        return $http.put('/license/', v.filter(function(it){
          return this$.hash[it];
        })).success(function(d){
          return d.map(function(it){
            if (!this$.hash[it.pk]) {
              return this$.item(it.pk, it);
            }
          });
        });
      },
      init: function(){
        this['new'].init();
        return $('#lic-new-modal').modal('setting', 'closable', false).modal('show').show();
      },
      'new': {
        item: {},
        init: function(){
          return this.item = $.extend(true, {}, import$({}, this.initData));
        },
        initData: {
          name: {
            p: true,
            v: ""
          },
          desc: {
            p: true,
            v: ""
          },
          url: {
            p: true,
            v: ""
          },
          pd: false,
          at: false,
          sa: false,
          nd: false,
          nc: false,
          file: null
        },
        trim: function(){
          var this$ = this;
          return ['name', 'desc', 'url'].map(function(it){
            var that;
            if (that = this$.item[it].v) {
              return this$.item[it].v = that.trim();
            }
          });
        },
        save: function(){
          var this$ = this;
          this.trim();
          if (['name', 'desc'].map(function(it){
            return this$.item[it].p = !!this$.item[it].v;
          }).filter(function(it){
            return !it;
          }).length) {
            return $('#lic-new-modal .error-hint.missed').show().delay(2000).fadeOut(1000);
          }
          $('#lic-new-form-pxy').load(function(){
            return $('#lic-new-modal').hide();
          });
          return $('#lic-new-form').submit();
        }
      }
    },
    gh: {
      list: [],
      hash: {},
      item: function(k, v){
        if (v && !(k in this.hash)) {
          return this.hash[k] = v;
        } else {
          return this.hash[k];
        }
      },
      trim: function(o){
        var k, this$ = this;
        ['name', 'desc', 'author', 'author_url'].map(function(it){
          if (it in o && o[it].v) {
            return o[it].v = o[it].v.trim();
          }
        });
        return (function(){
          var results$ = [];
          for (k in {
            name: o.name,
            author: o.author,
            license: o.license,
            tags: o.tags
          }) {
            results$.push(o[k].p = !o[k].v ? false : true);
          }
          return results$;
        }()).filter(function(it){
          return !it;
        }).length;
      },
      modal: {
        title: "Upload Icon"
      },
      'new': {
        h: {
          init: function(){
            var this$ = this;
            $('#glyph-new-form-pxy').load(function(){
              return this$.proxy();
            });
            return this.init = function(){
              return true;
            };
          },
          proxy: function(){
            return this.main();
          },
          main: null,
          set: function(it){
            return this.init() && (this.main = it);
          }
        },
        n: null,
        init: function(){
          var x$;
          this.list.data = [];
          $scope.gh.modal.title = "Upload Icons";
          this.n = this.item.data = $.extend(true, {}, import$({}, this.initData));
          x$ = $('#glyph-new-modal').modal('setting', 'context', '#footer').modal('setting', 'closable', false).modal('show');
          x$.find('.single').show();
          x$.find('.multiple').hide();
          return x$;
        },
        list: {
          data: [],
          save: function(){
            var i$, ref$, len$, d, k;
            for (i$ = 0, len$ = (ref$ = this.data).length; i$ < len$; ++i$) {
              d = ref$[i$];
              $scope.gh.trim(d);
              for (k in {
                name: d.name,
                author: d.author,
                license: d.license,
                tags: d.tags
              }) {
                d[k].p = !d[k].v ? false : true;
              }
            }
            $scope.gh['new'].h.set(this.callback);
            return $('#glyph-new-form').submit();
          },
          callback: function(){
            var pks, this$ = this;
            pks = JSON.parse($('#glyph-new-form-pxy').contents().find('body').html());
            if (pks.length === $scope.gh['new'].list.data.length) {
              $('#glyph-new-modal').modal('hide');
              return $scope.qr.load();
            } else {
              $('#glyph-new-modal .error-hint.missed').show().delay(2000).fadeOut(1000);
            }
            return $scope.$apply(function(){
              return $scope.gh['new'].list.data = $scope.gh['new'].list.data.filter(function(it){
                return !in$(it.id, pks);
              });
            });
          }
        },
        item: {
          data: {},
          save: function(){
            var k;
            $scope.gh.trim(this.data);
            if ((function(){
              var ref$, results$ = [];
              for (k in {
                name: (ref$ = this.data).name,
                author: ref$.author,
                license: ref$.license,
                tags: ref$.tags
              }) {
                results$.push(!(this.data[k].p = !this.data[k].v ? false : true));
              }
              return results$;
            }.call(this)).filter(function(it){
              return it;
            }).length > 0) {
              if (!$('#glyph-new-svg').val()) {
                this.data.svg.p = false;
              }
              return $('#glyph-new-modal .error-hint.missed').show().delay(2000).fadeOut(1000);
            }
            if (!$('#glyph-new-svg').val()) {
              return this.data.svg.p = false;
            }
            $scope.gh['new'].h.set(this.callback);
            return $('#glyph-new-form').submit();
          },
          callback: function(){
            var pks, f;
            pks = JSON.parse($('#glyph-new-form-pxy').contents().find('body').html());
            if (pks.length === 0) {
              return $('#glyph-new-modal .error-hint.error').show().delay(2000).fadeOut(1000);
            }
            f = document.getElementById('glyph-new-svg').files;
            if (f.length === 1) {
              $('#glyph-new-modal').modal('hide');
              return $scope.qr.load();
            }
            angular.element('#glyph-new-modal').scope().$apply(function(){
              var i, x;
              $scope.gh['new'].list.data = (function(){
                var i$, ref$, len$, ref1$, ref2$, results$ = [];
                for (i$ = 0, len$ = (ref$ = f).length; i$ < len$; ++i$) {
                  i = i$;
                  x = ref$[i$];
                  results$.push($.extend(true, {}, (ref2$ = {
                    id: pks[i],
                    svg: "svg/" + x.name
                  }, ref2$.name = (ref1$ = $scope.gh['new'].item.data).name, ref2$.author = ref1$.author, ref2$.author_url = ref1$.author_url, ref2$.license = ref1$.license, ref2$.tags = ref1$.tags, ref2$)));
                }
                return results$;
              }());
              return $scope.gh.modal.title = "Edit Icons Detail";
            });
            $("#glyph-new-modal .multiple").show();
            $("#glyph-new-modal .single").hide();
            return $('#glyph-new-modal').modal('refresh');
          }
        },
        initData: {
          name: {
            p: true,
            v: ""
          },
          author: {
            p: true,
            v: ""
          },
          author_url: {
            p: true,
            v: ""
          },
          license: {
            p: true,
            v: ""
          },
          tags: {
            p: true,
            v: ""
          },
          svg: {
            p: true,
            v: "(no file selected)",
            set: function(v){
              var this$ = this;
              return $scope.$apply(function(){
                var f, res$, i$, ref$, len$, x;
                res$ = [];
                for (i$ = 0, len$ = (ref$ = document.getElementById('glyph-new-svg').files).length; i$ < len$; ++i$) {
                  x = ref$[i$];
                  res$.push(x.name);
                }
                f = res$;
                return this$.v = f.length > 1
                  ? f[0] + "\n... (" + f.length + " files)"
                  : f.length === 1 ? f[0] + "" : "(no file selected)";
              });
            }
          }
        }
      },
      edit: {
        item: {},
        init: function(e, g){
          var x$, this$ = this;
          console.log(g);
          this.item = $.extend(true, {}, import$({}, $scope.gh['new'].initData));
          ['name', 'author', 'author_url', 'svg'].map(function(it){
            return this$.item[it].v = g[it] || "";
          });
          x$ = this.item;
          x$.tags.v = g.tags.map(function(it){
            return {
              id: it,
              text: it
            };
          });
          x$.license.v = $scope.lc.item(g.license.pk);
          x$.pk = g.pk;
          e.stopPropagation();
          return $('#glyph-edit-modal').modal('show');
        },
        flat: function(g){
          var ret, i$, ref$, len$, k, x$;
          ret = {};
          for (i$ = 0, len$ = (ref$ = ['name', 'author', 'author_url']).length; i$ < len$; ++i$) {
            k = ref$[i$];
            ret[k] = (g[k] && g[k].v) || (g[k] || "");
          }
          x$ = ret;
          x$.license = g.license.v.pk;
          x$.tags = g.tags.v.map(function(it){
            return it.id;
          }).join(',');
          return x$;
        },
        save: function(){
          var this$ = this;
          if ($scope.gh.trim(this.item)) {
            return $('#glyph-edit-modal .error-hint.missed').show().delay(2000).fadeOut(1000);
          }
          return $http.put("/glyph/" + this.item.pk + "/", this.flat(this.item)).success(function(d){
            if (in$(this$.item.pk, d)) {
              return $('#glyph-edit-modal').modal('hide');
            } else {
              return $('#glyph-edit-modal .error-hint.missed').show().delay(2000).fadeOut(1000);
            }
          });
        }
      }
    }
  });
  $scope.lc.fetch();
  $scope.st.init();
  $scope.qr.init();
  return $scope.hv = {
    edit: {
      item: {},
      handle: function($event, g){
        this.item = g;
        return $('#glyph-edit-modal').modal('show');
      }
    },
    item: {},
    h: null,
    handle: function($event, g){
      if (this.h) {
        clearTimeout(this.h);
        this.h = null;
      }
      if (!g) {
        return this.h = setTimeout(function(){
          return $('#icon-hint').fadeOut();
        }, 1000);
      } else {
        this.item = g;
        return setTimeout(function(){
          var e, p, x$, n, left, ref$;
          e = $($event.target);
          while (!e.hasClass('svg-icon') && e.length) {
            e = e.parent();
          }
          p = e.offset();
          if (!p) {
            return;
          }
          x$ = n = $('#icon-hint');
          x$.fadeIn();
          x$.css({
            top: (2 + p.top + e.outerHeight()) + "px",
            left: '0px'
          });
          n = $("#icon-hint .ib");
          left = e.width() / 2 + p.left - n.outerWidth() / 2 - 50;
          left >= 10 || (left = 10);
          left <= (ref$ = $('body').outerWidth() - n.outerWidth() - 10) || (left = ref$);
          n.css({
            marginLeft: left + "px"
          });
          n = $("#icon-hint .arrow");
          left = e.width() / 2 + p.left - n.outerWidth() / 2;
          return n.css({
            marginLeft: left + "px"
          });
        }, 0);
      }
    }
  };
};
function deepEq$(x, y, type){
  var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
      has = function (obj, key) { return hasOwnProperty.call(obj, key); };
  var first = true;
  return eq(x, y, []);
  function eq(a, b, stack) {
    var className, length, size, result, alength, blength, r, key, ref, sizeB;
    if (a == null || b == null) { return a === b; }
    if (a.__placeholder__ || b.__placeholder__) { return true; }
    if (a === b) { return a !== 0 || 1 / a == 1 / b; }
    className = toString.call(a);
    if (toString.call(b) != className) { return false; }
    switch (className) {
      case '[object String]': return a == String(b);
      case '[object Number]':
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        return +a == +b;
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') { return false; }
    length = stack.length;
    while (length--) { if (stack[length] == a) { return true; } }
    stack.push(a);
    size = 0;
    result = true;
    if (className == '[object Array]') {
      alength = a.length;
      blength = b.length;
      if (first) { 
        switch (type) {
        case '===': result = alength === blength; break;
        case '<==': result = alength <= blength; break;
        case '<<=': result = alength < blength; break;
        }
        size = alength;
        first = false;
      } else {
        result = alength === blength;
        size = alength;
      }
      if (result) {
        while (size--) {
          if (!(result = size in a == size in b && eq(a[size], b[size], stack))){ break; }
        }
      }
    } else {
      if ('constructor' in a != 'constructor' in b || a.constructor != b.constructor) {
        return false;
      }
      for (key in a) {
        if (has(a, key)) {
          size++;
          if (!(result = has(b, key) && eq(a[key], b[key], stack))) { break; }
        }
      }
      if (result) {
        sizeB = 0;
        for (key in b) {
          if (has(b, key)) { ++sizeB; }
        }
        if (first) {
          if (type === '<<=') {
            result = size < sizeB;
          } else if (type === '<==') {
            result = size <= sizeB
          } else {
            result = size === sizeB;
          }
        } else {
          first = false;
          result = size === sizeB;
        }
      }
    }
    stack.pop();
    return result;
  }
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}