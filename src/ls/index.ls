<- $ document .ready
console.log ( $ \.license-chooser )
$ \.license-chooser .select2 do
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

$ \.tags .select2 do
  tokenSeparators: [",", " "]
  multiple: true
  data: []
  createSearchChoice: (term,data) ->
    if data.filter(-> (it.text.locale-compare term)==0).length==0 => return {id:term, text:term}
