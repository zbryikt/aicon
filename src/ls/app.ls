angular.module \main, <[ui.select2 utils]>
.config ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-CSRFToken"] = $.cookie \csrftoken
  $.fn.modal.settings.selector.close = "-nop-"

if typeof String.prototype.trim === "undefined"
    String.prototype.trim = ->
        return String(this).replace(/^\s+|\s+$/g, '');

main = ($scope, $http) ->
  $scope = $scope <<< do
    build-font: ->
      $scope.st.save!
      console.log "building: #{($scope.st.cur.icons.map (-> it.pk))}"
      $http.post \/build/, ($scope.st.cur.icons.map (-> it.pk))
      .success (d) ->
        if d and d.name =>
          console.log "redirect to /build/#{d.name}"
          window.location.href = "/build/#{d.name}"
        else console.log "build font failed."
    ui:
      detail: true
    st:
      sets: []
      init: -> $http.get \/iconset/ .success (d) ~>
        @sets = d
        @chk!
      len: 0
      name: "圖示集"
      list: {}
      show: false
      cur: icons: [] name: "圖示集" pk: -1
      chk: (rmed=null) ->
        if !@sets.length => @new!
        if !rmed or rmed==@cur => @load @sets.0
      rmset: (e, s) ->
        if s and s.pk>=0 =>
          $http.delete "/iconset/#{s.pk}"
          .success (d) ~>
            if @sets.indexOf(s) + 1 => @sets.splice(that - 1, 1)
            @chk s
        else if @sets.indexOf(s) + 1 =>
          @sets.splice(that - 1, 1)
          @chk s
      toggle: ->
        @show = !@show
        if @show => $ ".ico-li.iconset .ib" .show!
        else $ ".ico-li.iconset .ib" .hide!
      add: (g) ->
        if (g.added = if @list[g.pk] => @len-- and delete @list[g.pk] and false else (@list[g.pk] = g) and true) => @len++ and that
        @save-buf!
      clean: -> [k for k of @list]map ~>
        @list[it]added = false
        delete @list[it]
        @len--
      rand-name: -> <[圖示集 我的集合 尚未命名 還沒取名 新集合 超棒列表]>[parseInt Math.random!* *]
      new-count: 0
      new: ->
        @sets.push @load cover: "default/unknown.svg", icons: [], name: @rand-name!, pk: --@new-count
      load: (s) ->
        @save!
        @clean!
        @cur = s
        @name = s.name
        s.icons.map ~> @add $scope.gh.item it.pk, it
        s
      save-timer: null
      save-buf: ->
        if @save-timer => clearTimeout @save-timer
        @save-timer = setTimeout ~>
          @save-timer = null
          @save!
        , 5000
      save: ->
        if @save-timer =>
          clearTimeout @save-timer
          @save-timer = null
        if !@len => return
        @cur{name,icons} = {name: @name, icons: []}
        [k for k of @list]map ~> @cur.icons.push @list[it]
        des = @cur
        $http.post \/iconset/, {pk: @cur.pk, name: @name, icons: [k for k of @list]map(~>@list[it]pk)}
        .success (d) ~>
          if des.pk == -1 => des.pk = d.pk

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
          [$scope.gh.list, hash] = [[], {}]
          d.data.map -> $scope.gh.list.push $scope.gh.item it.pk, it
          d.data.map -> hash[it.license.pk] = 1
          $scope.lc.fetch [k for k of hash]
    # todo: how licenses are fetched? how if hash missed?
    lc:
      hash: {}
      item: (k,v) -> if v and !(k of @hash) => @hash[k] = v else @hash[k]
      load: -> $http.get \/license/ .success (d) ~> d.data.map ~> @item it.pk, it
      fetch: (v) ->
        if !v => return $.ajax \/license/, {dataType: \json} .success (d) ~> for it in d.data => @item it.pk, it
        $http.put \/license/, v.filter(~> @hash[it]) .success (d) ~>
          d.map ~> if !@hash[it.pk] => @item it.pk, it
      init: ->
        @new.init!
        $ \#lic-new-modal .modal \setting, \closable, false .modal \show .show!

      new:
        item: {}
        init: -> @item = $.extend true, {}, {} <<< @init-data
        init-data: name:{p:true,v:""}, desc:{p:true, v:""}, url:{p:true,v:""}, pd:false, at:false, sa:false, nd:false, nc:false, file:null
        trim: -> <[name desc url]>map ~> if @item[it]v => @item[it]v = that.trim!
        save: ->
          @trim!
          if <[name desc]>map(~> @item[it]p = !!@item[it]v)filter(->!it)length =>
            return $ '#lic-new-modal .error-hint.missed' .show!delay 2000 .fadeOut 1000
          $ \#lic-new-form-pxy .load -> $ \#lic-new-modal .hide!
          $ \#lic-new-form .submit!

    gh:
      list: []
      hash: {}
      item: (k,v) -> if v and !(k of @hash) => @hash[k] = v else @hash[k]
      trim: (o) ->
        <[name desc author author_url]>map ~> if (it of o) and o[it]v => o[it]v = o[it]v.trim!
        (for k of o{name,author,license,tags} => o[k]p = if !o[k]v => false else true)filter(->!it).length
      modal: title: "Upload Icon"
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
          $scope.gh.modal.title = "Upload Icons"
          @n = @item.data = $.extend true, {}, {} <<< @init-data
          #$ \#glyph-new-modal .modal \setting, \closable, false .modal \show
          $ \#glyph-new-modal .modal \setting, \context, \#footer  .modal \setting, \closable, false .modal \show
            ..find \.single .show!
            ..find \.multiple .hide!
        list:
          data: []
          save: ->
            for d in @data =>
              $scope.gh.trim d
              for k of d{name,author,license,tags} => d[k]p = if !d[k]v => false else true
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
            $scope.gh.trim @data
            if (for k of @data{name,author,license,tags} =>
              !@data[k].p = if !@data[k].v => false else true
            )filter(->it).length>0 =>
              if not ( $ \#glyph-new-svg .val! ) => @data.svg.p = false
              return $ '#glyph-new-modal .error-hint.missed' .show!delay 2000 .fadeOut 1000
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
              $scope.gh.modal.title = "Edit Icons Detail"
            $ "\#glyph-new-modal .multiple" .show!
            $ "\#glyph-new-modal .single" .hide!
            $ \#glyph-new-modal .modal \refresh
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

      edit:
        item: {}
        init: (e, g) ->
          console.log g
          @item = $.extend true, {}, {} <<< $scope.gh.new.init-data
          <[name author author_url svg]>map ~> @item[it]v = ( g[it] or "" )
          @item
            ..tags.v = g.tags.map -> {id: it, text: it}
            ..license.v = $scope.lc.item g.license.pk
            ..pk = g.pk
          e.stopPropagation!
          $ \#glyph-edit-modal .modal \show
        flat: (g) ->
          ret = {}
          for k in <[name author author_url]> => ret[k] = ((g[k] and g[k]v) or (g[k] or ""))
          ret
            ..license = g.license.v.pk
            ..tags = g.tags.v.map(-> it.id)join \,
        save: ->
          if $scope.gh.trim @item => return $ '#glyph-edit-modal .error-hint.missed' .show!delay 2000 .fadeOut 1000
          $http.put "/glyph/#{@item.pk}/", @flat @item .success (d) ~>
            if (@item.pk in d) => return $ \#glyph-edit-modal .modal \hide
            else $ '#glyph-edit-modal .error-hint.missed' .show!delay 2000 .fadeOut 1000


  $scope.lc.fetch!
  $scope.st.init!
  $scope.qr.init!

  $scope.hv =
    item: {}
    h: null
    handle: ($event, g) ->
      if @h =>
        clearTimeout @h
        @h = null
      if !g =>
        @h = setTimeout (-> $ \#icon-hint .fadeOut!), 1000
      else
        @item = g
        setTimeout -> # calculate after angular render 
          e = $ $event.target
          while !e.hasClass(\svg-icon) and e.length => e = e.parent!
          p = e.offset!
          if not p => return
          n = $ \#icon-hint
            ..fadeIn!
            ..css top: "#{2 + p.top + e.outerHeight!}px", left: \0px
          n = $ "\#icon-hint .ib"
          left = e.width! / 2 + p.left - n.outerWidth! / 2 - 50
          left>?=10
          left<?=( $ \body .outerWidth! - n.outerWidth! - 10 )
          n.css marginLeft: "#{left}px"
          n = $ "\#icon-hint .arrow"
          left = e.width! / 2 + p.left - n.outerWidth! / 2
          n.css marginLeft: "#{left}px"
        ,0
