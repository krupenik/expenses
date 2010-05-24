$(function() {
  // filter form
  $("#tags_filter_form").submit(function() {
    var url = this.action;
    var query_string = $("#tags").val().replace(/\s*([()!|,])\s*/g, '$1');
    document.location = url + "/" + query_string + document.location.hash;
    return false;
  });
});
