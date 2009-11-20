/*
  Class: Skyline.HoverSelect
  Use this to replace select boxes with a span. The selectbox will reappear on 
  mouseover.
*/
Skyline.HoverSelect = new Class({
  initialize : function(element){
    this.element = $(element);
    this._createClickElement();
    this._attachEvents();
    this._hideSelect();
  },
  _setClickElementText : function(){
    this.clickElement.set("html",this.element.getSelected().get("html"));
  },
  _showSelect : function(event){
    event.stop();
    this.element.setStyle("display", "inline");
    this.clickElement.setStyle("display", "none");
  },
  _hideSelect : function(){
    this.element.setStyle("display", "none");
    this.clickElement.setStyle("display", "inline");
    this._setClickElementText();
    this._setActive(false);
  },
  _setActive : function(value){
    this.element.store("Skyline.HoverSelect:active",value);
  },
  _isActive : function(){
    return this.element.retrieve("Skyline.HoverSelect:active");
  },
  _createClickElement : function(){
    this.clickElement = new Element("span",{});
    this.clickElement.inject(this.element,"before");
  },
  _attachEvents : function(){
    this.clickElement.addEvents({"mouseover" : this._showSelect.bindWithEvent(this)})
    this.element.addEvents({
      "mousedown" :this._setActive.bind(this,[true]), 
      "change": this._hideSelect.bind(this),
      "blur": this._hideSelect.bind(this), 
      "mouseout" : function(){if(!this._isActive()){ this._hideSelect();  }}.bind(this)
    });
  }
});