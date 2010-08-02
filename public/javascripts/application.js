$.datepicker.setDefaults({
  dateFormat: 'yy-mm-dd',
  firstDay: 1,
});

var App = {
  entries_tablesorter: false,
  entries_filter_overridden: false,

  init: function()
  {
    $("#flash_notice, #flash_alert").delay(10000).fadeOut().click(function() { $(this).hide(); });
    App.applyLayout();
    App.initHeader();
  },

  applyLayout: function() {
    var c = $("#container"); if (c[0]) {
      var prevs = [];
      if (null != (prevs[0] = c[0].previousElementSibling)) {
        while (null != (prevs[prevs.length] = prevs[prevs.length - 1].previousElementSibling));
      }
      c.css({
        position: "fixed", left: 0, right: 0, bottom: 0,
        top: prevs.map(function(e) { return $(e).outerHeight(true); }).reduce(function(a, e) { return a + e; }) || 0,
      });
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