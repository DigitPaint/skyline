Skyline.Editor.plugins.SkylineCode.Dialog = new Class({
  Extends: Skyline.RemoteDialog,
  initialize : function(ed){
    this.editor = ed;
    
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/javascripts/src/skyline.editor/dialogs/skyline_code.html",
    
    this.setOptions({width: 800, height: 500});

    this.parent(arguments[1]);
    
    this.addEvent("loaded",this._loaded.bind(this));
    this.addEvent("close",this._onClose.bind(this));
    this.open();
  },
  
  ok : function(){
    this.setSource();
    this.close();
  },
  
  cancel : function(){    
    this.close();
  },
  
  setSource : function(){
  	this.editor.setContent(this.sourceEditorEl.value, {source_view : true});
  },
  
  getSource : function(){
  	// Remove Gecko spellchecking
  	if (tinymce.isGecko){
  		document.body.spellcheck = this.editor.getParam("gecko_spellcheck");
  	}

  	this.sourceEditorEl.value = this.editor.getContent({source_view : true});   
  },
  /*
    Function: setWrap
    Set the wrapping on the textarea
    
    Parameters:
    
    val - The wrapping to set, can be "off" or "soft"
  */
  setWrap : function(val){
  	var v, n, s = this.sourceEditorEl;

  	s.wrap = val;

  	if (!tinymce.isIE) {
  		v = s.value;
  		n = s.cloneNode(false);
  		n.setAttribute("wrap", val);
  		s.parentNode.replaceChild(n, s);
  		n.value = v;
  		this.sourceEditorEl = $(n);
  	}    
  },
  
  setContent : function(html){
    this.parent(this.editor.translate(html));
  },
  
  setTitle : function(html){
    this.parent(this.editor.translate(html));
  },
  
  _onClose : function(){
    this.destroy();    
  },
    
  _loaded : function(){
    var d = this.contentEl.getElement(".dialog"), tp, tw;
    this.layout = new Skyline.VerticalLayout(d);

    this.sourceEditorEl = d.getElement("textarea.sourceEditor");
    var cp = this.layout.addPanel(d.getElement(".contentPanel"));
    cp.addPanel(this.sourceEditorEl);
    this.layout.addPanel(d.getElement(".footerPanel"), {height:"content"});      
    
    this.layout.setup();
    
    this.setWrap("off");    
    this.getSource();
  }
  
});