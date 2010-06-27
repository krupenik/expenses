$(function() {
  // filter form
  $("#context_form").submit(function() {
    var url = this.action;
    var query_string = $.param($.map($(this).serializeArray(), function(i) { return (i.value ? i : null)}));
    document.location = url + (query_string ? "?" + query_string : '') + (query_string ? document.location.hash : '');
    return false;
  });

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

  $("#context_form").$('<input type="button" value="reset" id="context_reset"/>');
  $("#context_reset").click(function()
  {
    $(':input', $(this.form)).each(function() {
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
    $(this.form).submit();
  });
});