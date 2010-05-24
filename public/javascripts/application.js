$.datepicker.setDefaults({
  dateFormat: 'yy-mm-dd',
  firstDay: 1,
});

var App = {
  init: function()
  {
    App.applyLayout(); $(window).resize(App.applyLayout);
  },

  applyLayout: function() {
    var c = $("#container"); if (c[0]) {
      c.height($(window).height() - c.position()['top']);
    }
  },
}

$(function() {
  App.init();
});