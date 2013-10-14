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
      cur: {}
      rmset: (e, s) ->
        $http.delete "/iconset/#{s.pk}"
        .success (d) ~> if @sets.indexOf(s) + 1 => @sets.splice(that - 1, 1)

      add: (g) -> if (g.added = if @list[g.pk] => delete @list[g.pk] and false else (@list[g.pk] = g) and true) => @len++ and that
      clean: -> [k for k of @list]map ~>
        @list[it]added = false
        delete @list[it]
        @len--
      load: (s) -> 
        @clean!
        @cur = s
        @name = s.name
        s.icons.map ~> @add $scope.gh.item it.pk, it
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
          console.log "qr.load", d
          d.data.map -> $scope.gh.list.push $scope.gh.item it.pk, it
    lc: 0
    gh:
      list: []
      hash: {}
      item: (k,v) -> if v and !(k of @hash) => @hash[k] = v else @hash[k]
      new: 0

  $scope.st.init!
  $scope.qr.init!
