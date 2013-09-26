<- $ document .ready
console.log ( $ \.license-chooser )
$ \.license-chooser .select2 do
  placeholder: "choose a license"
$ \.tags .select2 do
  tokenSeparators: [",", " "]
  multiple: true
  data: []
  createSearchChoice: (term,data) ->
    if data.filter(-> (it.text.locale-compare term)==0).length==0 => return {id:term, text:term}
