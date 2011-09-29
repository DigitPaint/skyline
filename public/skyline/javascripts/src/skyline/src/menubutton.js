/*
  Class: Skyline.MenuButton
*/
Skyline.MenuButton = new Class({
  Implements : [Options,Events],
  options : {
    "class" : "active",
    labelSelector : "dt",
    bodySelector : "dd",
    bodyAlign : "left",
    zindex: 100
  },
  initialize : function(containerId){
    this.containerEl = $(containerId);
    this._initButton();
    this._initGlobalObserver();
    this.active = false;
    this.setOptions(arguments[1]);
  },
  activate : function(){
    this.containerEl.addClass("active");
    var dimen = this.bodyEl.getSize();
    
    // Make body box at least as wide as the button
    if(dimen.x < this.buttonSize.x){
      this.bodyEl.setStyle("width",this.buttonSize.x);
    }
    var left = 0;
    if(this.options.bodyAlign == "right"){
      left = this.buttonSize.x - dimen.x + 10; // 10 px left padding for shadow
    }
    this.bodyEl.setStyles({top: this.buttonSize.y, left: left, zIndex: 110});
    
    Skyline.MenuButton.deactivateActive();
    Skyline.MenuButton.activeButton = this;
    
    this.applyZIndex(this.options.zindex);
    this.active = true;
  },
  deactivate : function(){
    this.containerEl.removeClass("active");
    // this.getIframe().setStyle("display", "none");
    this.restoreZIndex();
    Skyline.MenuButton.activeButton = null;
    this.active = false;
  },
  toggle : function(){
    if(this.active){
      this.deactivate();
    } else {
      this.activate();
    }
  },
  _initButton : function(){
    this.labelEl = this.containerEl.getElement(this.options.labelSelector);
    this.bodyEl = this.containerEl.getElement(this.options.bodySelector);
    this.buttonSize = this.containerEl.getSize();
    
    // Prevent IE selection.
    this.labelEl.onselectstart = function(){ return false; };
    this.labelEl.ondrag = function(){ return false; };
    
    // Events
    this.labelEl.addEvents({
      "mousedown" : function(ev){
        this.toggle();
        Event.stop(ev);      
      }.bindWithEvent(this),
      "mouseup" : function(ev){
        Event.stop(ev);
      }
    });
    
    this.containerEl.addEvent("mouseup",function(ev){
      var lnk = $(ev.target);
      if(!(lnk.get("tag") == "a")){
        lnk = lnk.getParent("a");
      }
      if(!lnk){
        Event.stop(ev);        
      }
      // this.deactivate();
    }.bindWithEvent(this));     
  },
  _initGlobalObserver : function(){
    if(Skyline.MenuButton.addedGlobalObserver){return true;}
    $(document).addEvents({
      "mouseup" : Skyline.MenuButton.deactivateActive,
      "blur" : Skyline.MenuButton.deactivateActive
    });
    Skyline.MenuButton.addedGlobalObserver = true;    
  },
  applyZIndex : function(zindex){
    var reindexed = this.reindexed = $A([]);
    
    this.containerEl.getParents().each(function(p){
      var s = p.getStyles("position","z-index");
      if(s.position == "relative" || s.position == "absolute"){
        reindexed.push(p);
        p.store("skyline.menubutton:origzindex",p["z-index"]);
        p.setStyle("z-index", zindex);
      }
    });
  },
  restoreZIndex : function(){
    if(!this.reindexed){ return; }
    this.reindexed.each(function(p){
      var z = p.retrieve("skyline.menubutton:origzindex");
      p.setStyle("z-index", z)
    });
    this.reindexed = null;
  }
});

// The activeButton
Skyline.MenuButton.activeButton = null;
Skyline.MenuButton.deactivateActive = function(){
  if(Skyline.MenuButton.activeButton){
    Skyline.MenuButton.activeButton.deactivate();
  }  
};
Skyline.MenuButton.addedGlobalObserver = false;
Skyline.MenuButton.buttons = {};