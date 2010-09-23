window.tinyMCEPreInit = {};
tinyMCEPreInit.suffix  = "";
tinyMCEPreInit.base = "/javascripts/skyline.editor";
tinyMCEPreInit.query = "";

//= require "../vendor/tinymce/jscripts/tiny_mce/tiny_mce"
//= require "../vendor/tinymce/jscripts/tiny_mce/plugins/paste/editor_plugin"

var __FILE__ = Skyline.Utils.getJsLocation("skyline.editor.js");

Skyline.Editor = new Class({
  Implements : [Options],
  options : {
    language : "en-EN",
    imageDialogUrl : "",
    toolbarContainer : "mceToolbarContainer",
    contentCss : __FILE__.base + "/../assets/content.css",
    popupCss : __FILE__.base + "/../assets/dialog.css",
    enableEditHtml : false,
    toolbars : [
      "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull",
      "bullist,numlist,|,outdent,indent,|,undo,redo,|,link,unlink,image",
      "sub,sup",
      "table"
    ]
  },
  tinyMceDefaults : {
    language : false,
    // The default list with added our own sklyine specific attributes.
    extended_valid_elements : "img[class|longdesc|usemap|src|border|alt=|title|hspace|vspace|width|height|align|skyline-ref-id|skyline-referable-id|skyline-referable-type]," 
      + "a[rel|rev|charset|hreflang|tabindex|accesskey|type|name|href|target|title|class|onfocus|onblur|skyline-ref-id|skyline-referable-id|skyline-referable-type]",
    theme : "-skyline",
    plugins : "-autoresize,-skylinewindows,-skylineimage,-skylinelink,-skylinecode,-paste,-skylinecontextmenu, -skylinetable",
		paste_strip_class_attributes : "all",
		relative_urls : false,
		height: 10
  },
  initialize : function(textareaEl){
    var o,ed;
    if(arguments.length > 1){ this.setOptions(arguments[1]); }
    
    
    this.element = $(textareaEl);
    this.elementId = this.element.get("id");
    this.render();
  },
  clear : function(){
    this.editor.focus();
    this.editor.remove();    
  },
  render : function(){
    var o,ed,oed;
    
    // We need to manually disable the activeEditor,
    // because otherwise we'd get multiple toolbars when adding new editors.
    oed = tinymce.EditorManager.activeEditor
    if (oed !== null && typeof oed !== "undefined"){
     oed.onDeactivate.dispatch(oed);
    }
    
    o = this.optionsForTinyMce();
    ed = this.editor = new tinymce.Editor(this.elementId,o);      
    this.editor.render();  
  },
  optionsForTinyMce : function(){
    var opts = {
      paste_preprocess : this.pastePreProcess
    };
    $H({
      imageDialogUrl : "skyline_image_dialog_url", 
      toolbarContainer : "skyline_toolbar_container", 
      contentCss : "content_css", 
      popupCss : "popup_css",
      language : "language"
    }).each(function(k,v){
      opts[k] = this.options[v];
    }.bind(this));
    
    opts.theme_advanced_toolbars = this.options.toolbars.slice(0); // Clone toolbar
    if(this.options.enableEditHtml){
      opts.theme_advanced_toolbars.push("code");
    }
    
    return $merge(this.tinyMceDefaults,opts);
  },
  focus :function(){
    var ed = this.editor;
    if(!ed.getWin()){
      ed.onInit.add(function(){
        ed.focus();
        ed.theme._onFocus();
      });
    } else {
      ed.theme._onFocus();      
      ed.focus(); 
    }
  },
  pastePreProcess : function(pl,o){
		var ed = this.editor, h = o.content;

		//console.log('Before preprocess:' + o.content);

		var process = function(items) {
			tinymce.each(items, function(v) {
				// Remove or replace
				if (v.constructor == RegExp){
				  h = h.replace(v, '');
				} else {
				  h = h.replace(v[0], v[1]);
				}
			});
		};
		
    // Remove all divs
    process([
      /<\/?(pre|code|img|font|meta|link|style|div|h\d)[^>]*>/gi, // Remove img/div etc.
      /<\/?(small|big)[^>]*>/gi // Remove small/big etc.
    ]);
    
    o.content = h;
  }
});

//= require "script_loader"
//= require "theme"
//= require "ui/separator"
//= require "ui/toolbar"
//= require "plugins/autoresize/editor_plugin"
//= require "plugins/skylinewindows/editor_plugin"
//= require "plugins/skylineimage/editor_plugin"
//= require "plugins/skylineimage/dialog"
//= require "plugins/skylinelink/editor_plugin"
//= require "plugins/skylinelink/dialog"
//= require "plugins/skylinecode/editor_plugin"
//= require "plugins/skylinecode/dialog"
//= require "plugins/skylinecontextmenu/editor_plugin"
//= require "plugins/skylinetable/editor_plugin"