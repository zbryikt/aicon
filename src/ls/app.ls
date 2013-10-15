angular.module \main, <[ui.select2 utils]>
.config ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie \csrftoken

main = ($scope, $http) ->
  $scope = $scope <<< do
    ui:
      detail: false
    st:
      sets: []
      init: -> $http.get \/iconset/ .success (d) ~> @sets = d
      len: 0
      name: "圖示集"
      list: {}
      cur: icon: [] name: "圖示集" pk: -1
      rmset: (e, s) ->
        if s and s.pk>=0 =>
          $http.delete "/iconset/#{s.pk}"
          .success (d) ~> if @sets.indexOf(s) + 1 => @sets.splice(that - 1, 1)
        else if @sets.indexOf(s) + 1 => @sets.splice(that - 1, 1)
        

      add: (g) -> if (g.added = if @list[g.pk] => delete @list[g.pk] and false else (@list[g.pk] = g) and true) => @len++ and that
      clean: -> [k for k of @list]map ~>
        @list[it]added = false
        delete @list[it]
        @len--
      rand-name: -> <[圖示集 我的集合 尚未命名 還沒取名 新集合 超棒列表]>[parseInt Math.random!* *]
      new: -> @sets.push @load cover: "default/unknown.svg", icons: [], name: @rand-name!, pk: -1
        
      load: (s) -> 
        @clean!
        @cur = s
        @name = s.name
        s.icons.map ~> @add $scope.gh.item it.pk, it
        s
      save: ->
        if !@len => return
        @cur{name,icons} = {name: @name, icons: []}
        [k for k of @list]map ~> @cur.icons.push @list[it]
        $http.post \/iconset/, {pk: @cur.pk, name: @name, icons: [k for k of @list]map(~>@list[it]pk)}

    qr: 
      keyword: ""
      timer: null
      init: ->
        $scope.$watch \query.keyword, ~>
          if @timer => clearTimeout @timer
          @timer = setTimeout (~>@load!), 700
      load: ->
        $http.get \/glyph/, {params: {q: @keyword, page_limit: 100}}
        .success (d) ->
          $scope.gh.list = []
          d.data.map -> $scope.gh.list.push $scope.gh.item it.pk, it
    lc: 0
    gh:
      list: []
      hash: {}
      item: (k,v) -> if v and !(k of @hash) => @hash[k] = v else @hash[k]
      new:
        # handler after uploading glyph
        h:
          init: ->
            $ \#glyph-new-form-pxy .load ~> @proxy!
            @init = (->true)
          proxy: -> @main!
          main: null
          set: -> @init! and @main = it
        n: null   # short-cut for gh.item.data
        init: ->
          @list.data = []
          @n = @item.data = $.extend true, {}, {} <<< @init-data
          $ \#glyph-new-modal .modal \show
            ..find \.single .show!
            ..find \.multiple .hide!
        list:
          data: []
          save: ->
            for d in @data => for k of d{name,author,license,tags} => d[k].p = if !d[k].v => false else true
            $scope.gh.new.h.set @callback
            $ \#glyph-new-form .submit!
          callback: ->
            pks = JSON.parse($ \#glyph-new-form-pxy .contents!find \body .html!)
            if pks.length == $scope.gh.new.list.data.length =>
              $ \#glyph-new-modal .modal \hide
              return $scope.qr.load!
            else $ '#glyph-new-modal .error-hint.missed' .show!delay 2000 .fadeOut 1000
            $scope.$apply ~> $scope.gh.new.list.data = $scope.gh.new.list.data.filter -> !(it.id in pks)
        item:
          data: {}
          save: ->
            if (for k of @data{name,author,license,tags} =>
              !@data[k].p = if !@data[k].v => false else true
            )filter(->it).length>0 => return
            if not ( $ \#glyph-new-svg .val! ) => return @data.svg.p = false
            $scope.gh.new.h.set @callback
            $ \#glyph-new-form .submit!
          callback: ->
            pks = JSON.parse($ \#glyph-new-form-pxy .contents!find \body .html!)
            if pks.length==0 => return $ '#glyph-new-modal .error-hint.error' .show!delay 2000 .fadeOut 1000
            f = document.getElementById \glyph-new-svg .files
            if f.length==1
              $ \#glyph-new-modal .modal \hide
              return $scope.qr.load!
            # for working in main frame
            angular.element \#glyph-new-modal .scope!$apply ->
              $scope.gh.new.list.data = for x,i in f =>
                $.extend true, {}, {id: pks[i], svg: "svg/#{x.name}"} <<< $scope.gh.new.item.data{name,author,author_url,license,tags}
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

  $scope.st.init!
  $scope.qr.init!
