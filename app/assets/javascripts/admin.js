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
  $(this).find('input').each(function() {
      var name = $(this).attr("name");
      var value = $(this).val();
      data[name] = value;
  });
  return data;
}

$.fn.onFormChange = function(callback) {
  console.log('onFormChange', this)
  $(this).on('change', 'input[name]', callback);
  $(this).on('input', 'select[name]', callback);
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
  });
}

$(document).ready(function() {
  
  // Initial show
  var $message = $('.message');
  if ($message.text().length == 0) $message.hide();
  else $message.delay(FADE_OUT_DELAY).fadeOut().empty();
  
  $('.admin-user-list').onFormChange(onUserRowChanged);
  $('.admin-entity-list').onFormChange(onEntityRowChanged);
  
  console.log('adding onEntityRemoveClicked', $('.admin-user-list .user-entity-remove'))
  $('.admin-user-list').on('click', '.user-entity-remove', onEntityRemoveClicked);
  $('.admin-user-list').on('change', '.user-entity-add', onEntityAdded);

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
    });
  } 

 
  function onEntityRemoveClicked() {
    var $entityTag = $(this).closest('.user-entity');
    var $tr = $(this).closest('tr');
    var userId = $tr.data('id');
    var entityId = $entityTag.data('entity-id');
    console.log("Removing USER,ENTITY", userId, entityId);
    $.post('/remove_user_entity', { user_id: userId, entity_id: entityId });
    $entityTag.remove();
  }
  
  function onEntityAdded(e) {
    console.log("ADDED entity", $(this).val(), e)
    var entityId = $(this).val();
    if (entityId == undefined) return alert("Not actually a new entiy");
    var entityName = $(this).find('option[value="'+entityId+'"]').text();
    $(this).find('option').prop('selected', false); // Deselect everything, should leave the first option selected
    var $tr = $(this).closest('tr');
    var userId = $tr.data('id');
    var $entity = $('<span class="user-entity" data-entity-id="' + entityId + '"><span>' + entityName + '</span><span class="user-entity-remove">&times;</span></span>')
    $tr.find('.user-entities').append($entity);
    $.post('/add_user_entity', { user_id: userId, entity_id: entityId });
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
