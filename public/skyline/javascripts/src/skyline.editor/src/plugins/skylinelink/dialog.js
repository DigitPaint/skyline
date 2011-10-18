Skyline.Editor.plugins.SkylineLink.Dialog = new Class({
  validAttributes : {
    "data-skyline-ref-id": "ref_id",
    "data-skyline-referable-id" : "referable_id",
    "data-skyline-referable-type" : "referable_type",
    "title" : "title",
    "href" : "url",
    "target" : "target"
  },
  initialize : function(ed){
    this.url = ed.settings.skyline_image_dialog_url
    this.editor = ed;
    this.editorSelection = ed.selection.getNode();
    this.editorLinkEl = ed.dom.getParent(this.editorSelection, "A");
    this.storeSelection();
    
  	if (this.editorLinkEl != null && this.editorLinkEl.nodeName == "A"){
  		this.edit = true
  	}
    this.dialog = new Application.LinkBrowser($merge(this._getParameters(this.editorLinkEl),{common:true}));
    this.dialog.addEvent("select", this.insert.bind(this));
    this.dialog.addEvent("cancel", this.cancel.bind(this));
    this.dialog.open();
    
  },
  insert : function(values){
    this.restoreSelection();
  	var ed = this.editor;
  	var elm, elementArray, i,attr;

  	elm = this.editorLinkEl

    attr = this._getAttributes(values);

  	// Remove element if there is no href
  	if (!attr.href || attr.href == "") {
  	  return this.remove();
  	}

  	ed.execCommand("mceBeginUndoLevel");

  	// Create new anchor elements
  	if (elm == null) {
  		ed.getDoc().execCommand("unlink", false, null);
  		ed.execCommand("CreateLink", false, "#mce_temp_url#", {skip_undo : 1});

  		elementArray = tinymce.grep(ed.dom.select("a"), function(n) {return ed.dom.getAttrib(n, 'href') == '#mce_temp_url#';});
  		for (i=0; i<elementArray.length; i++){
  		  elm = elementArray[i];
  		  ed.dom.setAttribs(elm,attr)
  		}
  	} else {
		  ed.dom.setAttribs(elm,attr)
  	}
  	
  	// Don't move caret if selection was image
  	if (elm.childNodes.length != 1 || elm.firstChild.nodeName != 'IMG') {
  		ed.focus();
  		ed.selection.select(elm);
  		ed.selection.collapse(0);
      this.storeSelection();
  	}

  	ed.execCommand("mceEndUndoLevel");
  },
  cancel : function(){
		this.editor.focus();    
  },
  remove : function(){
    var ed = this.editor, i;
		ed.execCommand("mceBeginUndoLevel");
		i = ed.selection.getBookmark();
		ed.dom.remove(this.editorLinkEl, 1);
		ed.selection.moveToBookmark(i);
		ed.execCommand("mceEndUndoLevel");
  },
  // Get attributes from IMG tag for passing to dialog
  _getParameters : function(el){  
    if(!this.edit){ return {"new": true}; }
    var ed = this.editor, attr = {"new": false};
    $H(this.validAttributes).each(function(v,k){
      attr[v] = ed.dom.getAttrib(el,k);
    });
    return attr
  },
  // Get attributes from dialog for Element
  _getAttributes : function(values){
    var attr = {};
    $H(this.validAttributes).each(function(v,k){
      attr[k] = values[v];
    });    
    return attr;
  },
  
	/**
	 * Stores the current editor selection for later restoration. This can be useful since some browsers
	 * looses it's selection if a control element is selected/focused inside the dialogs.
	 */
	storeSelection : function() {
		this.editor.windowManager.bookmark = this.editor.selection.getBookmark(1);
	},

	/**
	 * Restores any stored selection. This can be useful since some browsers
	 * looses it's selection if a control element is selected/focused inside the dialogs.
	 */
	restoreSelection : function() {
		if (tinymce.isIE){
			this.editor.selection.moveToBookmark(this.editor.windowManager.bookmark);
		}
	}  
  
});