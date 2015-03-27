var FADE_OUT_DELAY = 8000;

function isRowModified(tr) {
  var inputs = $(tr).find('input');
  var modified = false;
  for (var i = 0; i < inputs.length; i++) {
    var input = $(inputs[i]);
    if (input.val() != input.attr('data-initial-value')) return true;
  }
  return false;
}

$.fn.getFormValues = function() {
  var data = {};
  $(this).find('input, select').each(function() {
      var name = $(this).attr("name");
      var value = $(this).val();
      data[name] = value;
  });
  return data;
}

$.fn.onFormChange = function(callback) {
  console.log('onFormChange', this)
  $(this).on('change', 'input', callback);
  $(this).on('input', 'select', callback);
}

// Initial values (i.e. values that reflect what's in the backend)
$.fn.saveInitialValues = function() {
  var $this = $(this);
  $this.attr('data-initial-value', $this.val());
}

$.fn.revertToInitialValues = function() {
  var $this = $(this);
  $this.each(function() {
    var $$this = $(this);
    var iv = $$this.attr('data-initial-value');
    if (iv != undefined) {
      $$this.val(iv);
    }  
  })
}

$(document).ready(function() {
  
  // Initial show
  var $message = $('.message');
  if ($message.text().length == 0) $message.hide();
  else $message.delay(FADE_OUT_DELAY).fadeOut().empty();
  
  $('.admin-user-list').onFormChange(onUserRowChanged);
  $('.admin-entity-list').onFormChange(onEntityRowChanged);

  function onEntityRowChanged() {
    var tr = $(this).closest('tr');
    var rowData = tr.getFormValues();
    rowData['id'] = tr.data('id');
    console.log("Going to save entity:", rowData);
    
    $.post("/update_entity", rowData, function(response) {
      if (response.message) {
        $message.show().text(response.message).delay(FADE_OUT_DELAY).fadeOut();
      }
      
      if (!response.status) {
        $(tr).find('input').revertToInitialValues();
      } else {
        $(tr).find('input').saveInitialValues();
      }
    })
  } 

 
  
  function onUserRowChanged() {
    var tr = $(this).closest("tr");
    //var isModified = isRowModified();
    var rowData = tr.getFormValues();
    rowData["id"] = tr.data("id");

    $.post("/update_user", rowData, function(response) {
      if (response.message) {
          $message.show().text(response.message).delay(FADE_OUT_DELAY).fadeOut();
      }
      if (!response.status) {
        $(tr).find('input').revertToInitialValues();
      } else {
        $(tr).find('input').saveInitialValues();
      }
    })
  }
});


window._autosaveTimeout;

function delayedOnRowChanged() {
  if (window._autosaveTimeout) {
    clearTimeout(window._autosaveTimeout);
  }

  window._autosaveTimeout = setTimeout(performSave, 4000);
}
