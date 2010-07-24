$.datepicker.setDefaults({
  dateFormat: 'yy-mm-dd',
  firstDay: 1,
});

var App = {
  entries_tablesorter: false,
  entries_filter_overridden: false,

  init: function()
  {
    var flashes = ["#flash_notice", "#flash_alert"];
    for (var i = 0; i < flashes.length; i++) {
      $(flashes[i]).delay(3000).fadeOut();
    }
    App.applyLayout(); $(window).resize(App.applyLayout);
    App.initHeader();
  },

  applyLayout: function() {
    var c = $("#container"); if (c[0]) {
      c.height($(window).height() - c.position()['top']);
    }
  },

  resetForm: function(form) {
    $(':input', $(form)).each(function() {
      var type = this.type;
      var tag = this.tagName.toLowerCase(); // normalize case
      if (type == 'text' || type == 'password' || tag == 'textarea') {
        this.value = '';
      }
      else if (type == 'checkbox' || type == 'radio') {
        this.checked = false;
      }
      else if (tag == 'select') {
        this.selectedIndex = -1;
      }
    });
    $(form).submit();
  },

  initHeader: function() {
    if ('' == $("#f_created_at").val() && '' == $("#f_type").val()) { $("#context_reset").attr("disabled", true); }
    if ('date' != $("#f_created_at").val()) {
      $("#context_apply").attr("disabled", true);
      $("#f_created_at_interval").hide();
    }

    $("#f_created_at_interval .datepicker").datepicker();

    $("#f_created_at").change(function() {
      $this = $(this);
      if ('date' == $this.val()) {
        $("#f_created_at_interval").show();
        $("#context_apply").attr("disabled", false);
      }
      else {
        $("#context_apply").attr("disabled", true);
        $("#f_created_at_interval .datepicker").each(function() { $(this).val(''); });
        $("#f_created_at_interval").hide();
        $(this.form).submit();
      }
    });

    $("#f_type").change(function() { $(this.form).submit(); });

    $("#context_reset").click(function() { App.resetForm(this.form); });
  },
}

$(function() {
  App.init();
});