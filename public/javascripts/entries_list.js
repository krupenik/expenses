$(function() {
  // tablesorter
  if (App.entries_tablesorter) {
    var sort_by = {};
    var sortable_by = ['id', 'created_at', 'amount', 'comment', 'tags'];
    var sort_orders = ['desc', 'asc'];

    sort_by['column'] = sortable_by.indexOf(document.location.hash.replace(/^#/, '').split(/\s*,/)[0]);
    sort_by['order'] = sort_orders.indexOf(document.location.hash.split(/\s*,\s*/)[1]);

    // default sort: created_at,desc
    if (-1 == sort_by['column']) { sort_by['column'] = 1; }
    if (-1 == sort_by['order']) { sort_by['order'] = 1; }

    $("#entries thead th").click(function() {
      $.tablesorter.headerClicked = true;
    });
    $("#entries").tablesorter({
      cssAsc: 'sort_asc',
      cssDesc: 'sort_desc',
      sortList: [[sort_by['column'], sort_by['order']]],
      headers: {
        0: { sorter: 'digit' },
        1: { sorter: 'isoDate' },
        2: { sorter: 'digit' },
        3: { sorter: 'text' },
        4: { sorter: 'text' },
      }
    }).bind("sortEnd", function(e) {
      if (!$.tablesorter.headerClicked) { return; }
      if (1 < this.config.sortList.length) { return; } // prevent hash change for multisort

      var l = $(this.config.headerList);
      l.each(function() {
        var m = this.className.match(/sort_(asc|desc)/);
        if (m) { document.location.hash = sortable_by[l.index(this)] + "," + m[1]; }
      });
    });
  }
});
