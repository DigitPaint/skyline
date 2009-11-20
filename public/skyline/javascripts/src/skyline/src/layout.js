Skyline.Layout  = new Class({
  Implements: [Options,Events],
  options: {
    width: null,
    height: null,
    minWidth: 0,
    minHeight: 0,
    hidden: false,
    zIndex: null
  },
  initialize : function(element){
    this.element = $(element);
    this.domId = this.element.get("id");
    
    this.panels = [];
    this.parent = null;
    this.hidden = false;
    this.addSplitterBeforeNext = false;
    
    var o = arguments[1];
    if(this.element.parentNode.tagName == 'BODY' && !(o && (o.width || o.height))){
      this.attachWindowEvents();
    }
    
    // If the parentNode is a dialog, adopt the size from the dialog.
    var d = $(this.element.parentNode).retrieve("skyline.dialog");
    if(d){
      var e = d.getSize();
      o = $merge(o,{width: e.x, height: e.y});
    }
    
    this.setOptions(o);
    
    if(this.options.hidden){
      this.hide(true);
    } else {
      this.show(true);
    }
        
    this.element.setStyles({
      position: "absolute",
      "z-index": this.options.zIndex
    });
    this.element.store("skyline.layout",this);
  },
  /*
    Function: addPanel(element)
    Add a new panel to this layout (a panel is just another layout)
    
    Options: 
    optional - Boolean, defaults to false/null if set just returns null if the element not exists.
  */
  addPanel : function(element){
    var layout = this.createPanel(element,arguments[1]);
    if(!layout){ return null; }
    
    if(this.addSplitterBeforeNext && this.panels.length > 0){
      var splitter = new Skyline.Splitter(this.panels.getLast(),layout);
      splitter.parent = this;
      this.addSplitterBeforeNext = false;
      this.panels.push(splitter);
    }
    
    this.panels.push(layout);
    return layout;
  },
  
  /*
    Function: createPanel(element)
    Create a new panel from a dom element, doesn't add it to the
    layout though. (Mostly used for internal stuff.)
  */
  createPanel : function(element){
    var layout, options = arguments[1], element = $(element);
    if(!element && options && options.optional){ return null; }
    
    layout = element.retrieve("skyline.layout");
    if(!layout){
      if(options && options["layout"] && options["layout"] == "horizontal"){
        layout = new Skyline.HorizontalLayout(element,options);
      } else {
        layout = new Skyline.VerticalLayout(element,options);
      }      
    } else {
      layout.setOptions(options);
    }
    layout.parent = this;
    return layout;
  },
  /*
    Function: replacePanel(origElement,element)
    Replace an existing panel
  */
  replacePanel : function(origElement,element){
    var nL, oL, panelIndex, pL;
    oL = $(origElement).retrieve("skyline.layout");
    if(!oL){ return; }  
    nL = this.createPanel(element,arguments[2]);            
    
    oL.element.setStyle("display","none");
    nL.element.setStyle("display","block");    
    
    panelIndex = this.panels.indexOf(oL);
    
    pL = this.panels[panelIndex - 1]; 
    if(pL && pL.splitter){
      pL.afterPanel = nL;
    }
    pL = this.panels[panelIndex + 1];
    if(pL && pL.splitter){
      pL.beforePanel = nL;
    }
    
    this.panels[panelIndex] = nL;
  
    return nL;
  },
  /*
    Function: show()
    Show this panel
  */  
  show : function(skipSetup){
    this.element.setStyle("display", "block");
    this.hidden = false;    
    if(this.parent && !skipSetup){this.parent.setup();}
  },
  /*
    Function: hide()
    Hide this panel
  */
  hide : function(skipSetup){
    this.element.setStyle("display", "none");
    this.hidden = true; 
    if(this.parent && !skipSetup){this.parent.setup();}    
  },
  /*
    Function: addSplitter()
    Add a splitter to the layout. Only adds a splitter if another panel is added.
  */
  addSplitter : function(){
    this.addSplitterBeforeNext = true;
  },
  
  /*
    Place the panels.
  */
  placePanels : function(){
    if(this.panels.length === 0){ return; }
    var pos = 0;
    this.panels.each(function(panel){
      if(panel.hidden){ return; }      
      pos = this.placePanelAt(panel,pos);
      panel.placePanels();
    }.bind(this));
  },
    
  /*
    Function: updateOptions()
    Takes the current width and height and writes it to options. Does not
    set options.width/options.height if the original value is not a number. (ie "content" or null)
  */
  updateOptions : function(){    
    if($type(this.options.width) == "number" || this.options.width == "content"){
      this.options.width = this.width;
    }
    if($type(this.options.height) == "number" || this.options.height == "content"){
      this.options.height = this.height;     
    }
  },
  setup : function(){
    if(!this.parent){
      this.width = this.options.width;
      this.height = this.options.height;
    }
    
    this.setupWidths();
    this.setupHeights();
    this.placePanels();
  },
  
  attachWindowEvents : function(){
    window.addEvent('resize', this.onWindowResize.bind(this));
    window.addEvent('domready', this.onWindowResize.bind(this));        
  },
  
  onWindowResize : function(){
    if (this.resizeTimer) {
      $clear(this.resizeTimer);
      this.resizeTimer = null;
    }
    
    var options = {width: window.getWidth(), height: window.getHeight()};    
    if(this.options.width != options.width || this.options.height != options.height){
      this.setOptions(options);
      this.setup();      
      this.resizeTimer = this.onWindowResize.delay(50, this);    
    }
  },
  
  // Implement in subclass
  placePanelAt: $empty,
  setPanelSize : $empty,
  setupWidths: $empty,
  setupHeights: $empty  
});

Skyline.HorizontalLayout = new Class({
  Extends: Skyline.Layout,
  orientation: "horizontal",
  placePanelAt : function(panel,pos){
    panel.position = pos;    
    panel.element.setStyles({"top":0, "left" : pos});    
    return pos + panel.width;
  },
  setPanelSize : function(panel,size){
    if(size < 0){ size = 0; }    
    panel.width = size;
    panel.element.setStyle("width", size);
  },  
  setupWidths : function(){
    this.element.setStyle("width",this.width);
    var rest = this.width;
    var variablePanel = null;
    this.panels.each(function(panel){
      if(panel.hidden){ return; }
      if(panel.options.width){
        if(panel.options.width == "content"){
          panel.element.setStyle("width","auto");        
          panel.width = panel.element.offsetWidth;          
        } else {
          panel.width = panel.options.width;
        }
        rest = rest - panel.width;
        this.setPanelSize(panel,panel.width);
        panel.setupWidths();          
      } else {
        variablePanel = panel;
      }
    }.bind(this));
    if(variablePanel){
      this.setPanelSize(variablePanel,rest);
      variablePanel.setupWidths();
    }
  },
  
  setupHeights : function(){
    this.element.setStyle("height",this.height);
    this.panels.each(function(panel){
      if(panel.hidden){ return; }      
      panel.height = this.height;
      panel.setupHeights();
    }.bind(this));
    
  }
});

Skyline.VerticalLayout = new Class({
  Extends: Skyline.Layout,
  orientation: "vertical",
  placePanelAt : function(panel,pos){
    panel.position = pos;    
    panel.element.setStyles({"left" : 0, "top" : pos});
    return pos + panel.height;
  },
  
  setPanelSize : function(panel,size){
    if(size < 0){ size = 0; }    
    panel.height = size;
    panel.element.setStyle("height", size);
  },

  setupWidths : function(){
    this.element.setStyle("width",this.width);
    this.panels.each(function(panel){
      if(panel.hidden){ return; }      
      panel.width = this.width;
      panel.setupWidths();
    }.bind(this));    
  },
  
  setupHeights : function(){
    this.element.setStyle("height",this.height);
    var rest = this.height;
    var variablePanel = null;
    this.panels.each(function(panel){
      if(panel.hidden){ return; }      
      if(panel.options.height){
        if(panel.options.height == "content"){
          panel.element.setStyle("height","auto");
          this.setPanelSize(panel,panel.element.offsetHeight);
        } else {
          this.setPanelSize(panel,panel.options.height);
        }
        rest = rest - panel.height;
        panel.setupHeights();
      } else {
        variablePanel = panel;
      }
    }.bind(this));
    if(variablePanel){
      this.setPanelSize(variablePanel,rest);      
      variablePanel.setupHeights();
    }
  }
  
});

Skyline.Splitter = new Class({
  Extends: Skyline.Layout,
  options: {
    width: "content",
    height: "content",
    zIndex: 2
  },
  splitter: true,
  initialize : function(beforePanel,afterPanel){
    this.beforePanel = beforePanel;
    this.afterPanel = afterPanel;    
    
    this.options.orientation = this.beforePanel.parent.orientation;
    if(this.options.orientation == "horizontal"){
      this.modifierKey = "x";
      this.sizeKey = "width";
    } else {
      this.modifierKey = "y";
      this.sizeKey = "height";      
    }
    
    var element = this.createElement();    
    this.parent(element,arguments[2]);
    this.attachDrag();
  },
  attachDrag : function(){
    var modifiers = {x: "left", y: "top"};
    var setModifiers = {x: null, y: null};
    setModifiers[this.modifierKey] = modifiers[this.modifierKey];    
    
    this.drag = new Drag(this.element, {
      snap : 0,
      modifiers : setModifiers
    });
    this.drag.addEvents({
      "snap" : this.onSnap.bind(this),
      "drag" : this.onDrag.bind(this),
      "complete" : this.onComplete.bind(this),
      "beforeStart" : this.onBeforeStart.bind(this)
    });
  },
  getDragLimits : function(){
    var minZ, ret = {};
    if(this.options.orientation == "horizontal"){
      minZ = "minWidth";
    } else {
      minZ = "minHeight";
    }
    
    var beforeLimit = this.beforePanel.position;
    var afterLimit = this.afterPanel.position + this.afterPanel[this.sizeKey] - this[this.sizeKey];
    if(this.beforePanel.options[minZ]){
      beforeLimit = beforeLimit + this.beforePanel.options[minZ];
    }
    if(this.afterPanel.options[minZ]){
      afterLimit = afterLimit - this.afterPanel.options[minZ];
    }
    
    ret[this.modifierKey] = [beforeLimit,afterLimit];
    return ret;
  },
  onSnap : function(){
    this.startPos = this.drag.value.now[this.modifierKey];
    this.startBeforeSize = this.beforePanel[this.sizeKey];
    this.startAfterSize = this.afterPanel[this.sizeKey];
    this.startAfterPos = this.afterPanel.position;
  },
  onBeforeStart : function(){
    this.drag.setOptions({
      limit: this.getDragLimits()
    });
  },
  onDrag : function(element){
    var curPos = this.drag.value.now[this.modifierKey];
    if(curPos == this.lastPos){ return; }
    var delta = this.startPos - curPos;
    
    this.parent.setPanelSize(this.beforePanel,this.startBeforeSize - delta);
    this.parent.setPanelSize(this.afterPanel, this.startAfterSize + delta);
    this.parent.placePanelAt(this.afterPanel, this.startAfterPos - delta);
    this.beforePanel.setup();
    this.afterPanel.setup();
    this.lastPos = curPos;
  },
  onComplete : function(){
    this.beforePanel.updateOptions();
    this.afterPanel.updateOptions();  
  },
  createElement : function(){
    var el = new Element("div",{"class": "splitter " + this.options.orientation ,"styles" : {
      zIndex: 10000000,
      position: "absolute"
    }});
    var inner = new Element("div");
    inner.inject(el);
    el.inject(this.beforePanel.element,"after");
    return el;
  },
  
  setupWidths : function(){
    this.element.setStyle("width",this.width);       
  },
  
  setupHeights : function(){
    this.element.setStyle("height",this.height);      
  }
});