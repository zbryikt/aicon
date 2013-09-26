$(document).ready(function(){
  console.log($('.license-chooser'));
  $('.license-chooser').select2({
    placeholder: "choose a license"
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