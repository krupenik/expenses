$(function() {
  // tags filter form
  $("#tags_filter_form").submit(function() {
    var url = this.action;
    var tags_string = $("#tags").val().replace(/\s*([()!|,])\s*/g, '$1');
    var query_string = $.param($.map($("#filter_form").serializeArray(), function(i) { return (i.value ? i : null)}));
    tags_string = tags_string ? "/" + tags_string : '';
    query_string = tags_string ? query_string ? "?" + query_string : '' : '';
    document.location = url + tags_string + query_string + (tags_string ? document.location.hash : '');
    return false;
  });

  // entries filter form override
  $("#filter_form").submit(function() {
    $("#tags_filter_form").submit();
    return false;
  });
  App.entries_filter_overridden = true;
});
