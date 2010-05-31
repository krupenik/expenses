$(function() {
  var $cloud = $("#cloud");

  Array.prototype.max = function() { return Math.max.apply(Math, this); }
  function f_dec(n) { return n.toFixed(2); };
  function f_int(n) { return n | 0; };

  function construct_cloud(criterion)
  {
    if ("by_appearance_rate" == criterion) {
      tags_data = tags_appearance_rates;
      data_f = f_int;
      document.location.hash = "by_appearance_rate";
    }
    else {
      tags_data = tags_expenses;
      data_f = f_dec;
      criterion = document.location.hash = 'by_expenses';
    }

    max_value = 0;
    for (i in tags_data) {
      if (max_value < tags_data[i] ) { max_value = tags_data[i]; }
    }

    $cloud.html('');
    for (i in tags) {
      if (tags_data[i]) {
        a = $("<a class='cl-" + f_int(10 * (tags_data[i] - 1) / max_value) +
          "' href='" + tag_path.replace("%s", tags[i]) + "'>" +
          tags[i] + " (" + data_f(tags_data[i]) + ")</a>");
        $cloud.append(a);
        $cloud.append(" ");
      }
    }

    $("#cloud_switcher span").removeClass("selected");
    $("#" + criterion).addClass("selected");
  }

  $("#cloud_switcher span").click(function() { construct_cloud(this.id); });
  construct_cloud(document.location.hash.replace("#", ''))
});