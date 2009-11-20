/*
  Class: Skyline.Toggle
  Attach an onclick event to one element and toggle classes on
  several others (including but not necessarily itself).
  
  The initial state can be set by setting the class on the toggleEl or if
  there is only one toggable, by setting it on the toggable.
  
  Events:
  toggle(state) - Called when the elements are toggled, the new state is passed as parameter.
  activate - Called when the toggler get's activate.
  deactivate - Called when the toggler get's deactivated.
  
*/
Skyline.Toggle = new Class({
  Implements: [Options,Events],
  options : {
    "class" : "active" 
  },
  initialize : function(toggleEl){
    var args = $A(arguments);
    if(arguments.length < 2){throw("At least give one element to toggle");}
    
    if($type(args.getLast()) == "object"){
      this.setOptions(args.pop());
    }
    
    this.toggleEl = $(args.shift());
    this.toggables = args.map(function(e){ return $(e); });
    this._getInitialState();
    this._attachEvents();
    this.toggleEl.store("skyline.toggle",this);
  },
  toggle : function(){
    if(this.active){
      this.deactivate();
    } else {
      this.activate();
    }
  },
  activate : function(){
    if(this.active){ return false; }
    this.toggables.each(function(e){ e.addClass(this.options["class"]); }.bind(this));
    this.active = true;
    this.fireEvent("activate");
    this.fireEvent("toggle",true);    
  },
  deactivate : function(){
    if(!this.active){ return false; }    
    this.toggables.each(function(e){ e.removeClass(this.options["class"]); }.bind(this));
    this.active = false;
    this.fireEvent("deactivate");
    this.fireEvent("toggle",false);    
  },
  _attachEvents : function(){
    this.toggleEl.addEvent("click",this.toggle.bind(this));
  },
  _getInitialState : function(){
    this.active = false;
    if(this.toggables.length == 1){
      this.active = this.toggables[0].hasClass(this.options["class"]);
    } else {
      this.active = this.toggleEl.hasClass(this.options["class"]);
    }
  }
});