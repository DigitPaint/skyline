var DeleteHelper = {
  /* ie: destroy('id') */
  destroy : function(fieldId) {
    var field = $(fieldId);    
    field.getElement("input.delete").value = '1';
    field.addClass('destroyed');
  },
  
  /* ie: undelete('field', 2) or undelete('field_value', 3) */
  unDestroy : function(fieldId) {
    var field = $(fieldId);
    field.getElement("input.delete").value = '0';
    field.removeClass('destroyed');
  }
};

var PageHelper = {
  contentChanged : false,
  currentVariantId : null,
    
  newVariantSelected : function(variantId) {
    $('change_variant_form').submit();
  },
  
  contentHasChanged : function() {
    this.contentChanged = true;
  },
  
  /* ie: destroy('id') */
  destroy : function(fieldId) {
    var field = $(fieldId);
    this.contentHasChanged();
    
    var value = field.match(".identifier input").value;
    if(value){
      field.select(".undestroy .value").each(function(v){
        v.update(value);
      });
    }
    DeleteHelper.destroy(field);
  },
  
  /* ie: undelete('field', 2) or undelete('field_value', 3) */
  unDestroy : function(fieldId) {
    var field = $(fieldId);
    this.contentHasChanged();
    DeleteHelper.unDestroy(field);
  }
};