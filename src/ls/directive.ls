angular.module \utils, <[]>
.directive \tags ($compile) ->
  return
    restrict: 'E'
    replace: true
    scope: {"model": '=ngModel', name: '@'}
    template: "<input type='hidden' class='tags' placeholder='add tags...'>"
    link: (scope, element, attrs) ->
      $ element .select2 do
        tokenSeparators: [",", " "]
        multiple: true
        data: []
        createSearchChoice: (term,data) ->
          if data.filter(-> (it.text.locale-compare term)==0).length==0 => return {id:term, text:term}
      .on \change (e) -> scope.$apply -> scope.model = $ element .select2 \data
      scope.$watch \model (v) -> $ element .select2 \data,  v
.directive \license ($compile) ->
  return
    restrict: 'E'
    replace: true
    scope: {"model": '=ngModel', name: '@'}
    template: "<input type='hidden'>"
    link: (scope, element, attrs) ->
      element .select2 do
        placeholder: "choose a license"
        minimumInputLength: 0
        ajax: do
          url: \/license/
          type: \GET
          dataType: \json
          quiteMillis: 100
          data: (term, page) -> q: term, page_limit: 10, page: page
          results: (d, p) -> results: d.data, more: d.hasNext
        initSelection: ->
        formatResult: -> (it.fields and "<div>#{it.pk}. #{it.fields and it.fields['name']}</div>") or ""
        formatSelection: -> (it.fields and "<div>#{it.pk}. #{it.fields['name']}</div>") or ""
        formatNoMatches: -> \找不到這個項目
        formatSearching: -> \搜尋中
        formatInputTooShort: -> \請多打幾個字
        id: (e) -> e.fields and "#{e.pk}" or ""
        escapeMarkup: -> it
      .on \change (e) -> scope.$apply -> scope.model = $ element .select2 \data
      scope.$watch \model (v) -> $ element .select2 \data,  v
.directive \icon, ($compile)->
  return
    restrict: 'E'
    replace: true
    scope: {"src": "@", "del": "&", "class": "@"}
    template:
      "<div class='svg-icon {{class}}'><div class='object'></div><div class='mask'></div>" +
      "<div class='delete' ng-click='$event.stopPropagation();del({e: $event})'>" +
      "<i class='icon remove'></i></div></div>"
    link: (scope, element, attrs) ->
      if !attrs.del => element.find \.delete .remove!
      if attrs.ngMouseover => element.on \mouseover (e) -> scope.$parent
        ..$event = e
        ..$apply attrs.ngMouseover
      if attrs.ngMouseout => element.on \mouseout (e) -> scope.$parent
        ..$event = e
        ..$apply attrs.ngMouseout
      if attrs.ngClick => element.on \click (e) -> scope.$parent
        ..$event = e
        ..$apply attrs.ngClick
      attrs.$observe \src, (v) ->
        # if in <object>:
        # if v => element.find \.object .replaceWith "<object class='object' type='image/svg+xml' data='/m/#{v}'></object>"
        # if in <iframe>:
        # if v => element.find \.object .replaceWith "<iframe class='object' src='/m/#{v}'></iframe>"
        if v =>
          if attrs.color =>
            node = $ "<iframe class='object' src='/m/#{v}'></iframe>"
            element.find \.object .replaceWith node
            node .load -> $(node.0.contentDocument)find("*").css(\fill, attrs.color)
          else => element.find \.object .replaceWith "<img class='object' src='/m/#{v}'>"
        else element.find \.object .replaceWith "<div class='object'>no data</div>"
