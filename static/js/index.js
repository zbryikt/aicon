$(document).ready(function(){
  console.log($('.license-chooser'));
  $('.license-chooser').select2({
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
  });
  return $('.tags').select2({
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
  });
});