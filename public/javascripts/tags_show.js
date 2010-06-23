$(function() {
  // tags filter form
  $("#tags_filter_form").submit(function() {
    var url = this.action;
    var tags_string = $("#tags").val().replace(/\s*([()!|,])\s*/g, '$1');
    document.location = url + (tags_string ? '/' + tags_string : '') + (tags_string ? document.location.hash : '');
    return false;
  });
});
