/*
  Class: Application.Sections
  Class to create section lists that are sortable.
*/
Application.Sections = new Class({
  Implements : [Options],
  options : {
    scrollParent : null
  },
  initialize : function(sectionsEl){
    this.element = $(sectionsEl);
    this.setOptions(arguments[1]);
    
    this.element.store("application.sections",this);
    
    if(!this.options.scrollParent){
      this.options.scrollParent = this.element.getOffsetParent();
    }
    
    this._initSortable();
  },
  
  activate : function(section){
    if(this.currentActive){
      this.currentActive.removeClass("active");
    }
    this.currentActive = section;
    this.currentActive.addClass("active");
  },
  
  getCurrentActiveId : function(){
    if($type(this.currentActive)){
      return this.currentActive.get("id");
    } else {
      return null;
    }
  },
  
  addSection : function(section){
    var section = $(section);
    this.sortable.addItem(section);
    this._initSection(section);
    
    // New sections should always be active
    this.activate(section);
  },
  
  // Privates methods
  _initSortable : function(){
    this.element.getChildren("li").each(function(el){this._initSection(el); }.bind(this));
    
    this.sortable = new Skyline.Sortable(this.element,{handle: "span.dragSection", clone: this._fakeSection, revert: true});
    this.contentScroller = new Scroller(this.options.scrollParent);
    this.sortable.addEvents({
      "start" : function(){ this.contentScroller.start(); }.bind(this),
      "stop" : function(){ this.contentScroller.stop(); this.contentScroller.detach(); }.bind(this),
      "beforeDrop" : function(el){
        var ed;
        if(ed = el.retrieve("skyline.editor")){
          var fn = function(ed){
            ed.element.setStyles({height: ed.editor.skyline_editor_height - 1, visibility: "hidden"});
            ed.clear();            
          }
          if($type(ed) == "array"){ 
            $A(ed).each(fn);
          } else {
            fn(ed);
          }
        }              
      },
      "afterDrop" : function(el){
        var ed;
        if(ed = el.retrieve("skyline.editor")){
          var fn = function(ed){
            ed.element.setStyles({height: 5, visibility: "visible"});
            ed.render();            
          }
          if($type(ed) == "array"){ 
            $A(ed).each(fn);
          } else {
            fn(ed);
          }
        }                            
      }
    });    
  },
  
  _initSection : function(section){
    var activate = (function(){this.activate(section)}).bind(this)
    section.addEvent("click", activate);
    section.getElements("input, select, textarea").addEvent("focus", activate);   
    setTimeout(function(){
      var ed;
      if(ed = section.retrieve("skyline.editor")){
        var fn = function(ed) {
          ed.addEvent("focus", activate);
        }
        if($type(ed) == "array"){ 
          $A(ed).each(fn);
        } else {
          fn(ed);
        }
      }
    },0);
  },
  
  _fakeSection : function(event,element,parent){
    var section = element.getElement("div.section"), sectionSize, clone, tools;
    sectionSize = section.getSize();

    clone = new Element("li",{"class" : "clone"}).setStyles({
      margin: '0px',
      position: 'absolute',
      visibility: 'hidden',
      opacity: 0.5
    });
    var es = clone.adopt(new Element("div",{"class" : "section"}).setStyles({"width": sectionSize.x, "height": sectionSize.y}));
    
    if(tools = element.getElement("ul.sectiontools")){
      clone.adopt(tools.clone(true));
    }
    
    return clone.inject(parent).position(element.getPosition(element.getOffsetParent()));;
  }  
});
