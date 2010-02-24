/*
  Class: Skyline.Tabs
  Class for a collection of tabs. Can also be used to create accordeons
  
  Options:
  activeClass - The class to set on the windowEl and tabEl when a tab is active. 
  
  Events:
  
  activateTab(tabs,tab)   - called when any tab get's activated.
  deactivateTab(tabs,tab) - called when any tab get's deactivated.
*/
Skyline.Tabs = new Class({
  Implements : [Events,Options],
  options : {
    activeClass : "active"    
  },
  initialize : function(){
    this.tabs = $A([]);
  },
  /*
    Function: addTab
    Add a new tab from the dom to the collection.
    
    Parameters:
    tabEl - The element which get's clicked to activate the tab
    windowEl - The element which get's activated on click
    
    Returns:
    A Skyline.Tab instance.
  */
  addTab : function(tabEl,windowEl){    
    var e = new Skyline.Tab(tabEl,windowEl,$merge(this.options,arguments[2]));
    return this.add(e);
  },
  /*
    Function: add
    Add a new tab by means of a Skyline.Tab instance.
    
    Parameters:
    tab - The Skyline.Tab instance to add.
    
    Returns:
    The added Skyline.Tab instance.
  */
  add : function(tab){
    tab.parent = this;
    tab.addEvent("activate",this.onActivateTab.bind(this));
    tab.addEvent("deactivate",this.onDeactivateTab.bind(this));    
    this.tabs.push(tab);
    return tab;
  },
  /*
    Function: setup
    Function to setup the initial state of the tabs collection. It also
    deactivates all but the currently active tab (determined from the DOM by means of activeClass).
    If no active tab is present, the first tab will be activated.
  */
  setup : function(){
    var a;
    this.tabs.each(function(tab){
      if(tab._isActive()){
        a = tab;
      }
      tab.deactivate();
    }); 
    if(a){
      a.activate();
    } else {
      this.tabs[0].activate();
    }
    
  },
  onActivateTab : function(tab){
    if(this.activeTab && this.activeTab != tab){
      this.activeTab.deactivate();
    }
    this.previouslyActiveTab = this.activeTab;
    this.activeTab = tab;
    this.fireEvent("activateTab",[this,tab]);
  },
  onDeactivateTab : function(tab){
    this.fireEvent("deactivateTab",[this,tab]);
  }
});

/*
  Class: Skyline.Tab
  Class for a single tab.
  
  Options:
  activeClass - The class to set on the windowEl and tabEl when a tab is active. 
  
  Events:
  
  activate   - called when the tab get's activated.
  deactivate - called when the tab get's deactivated.
*/
Skyline.Tab = new Class({
  Implements : [Events,Options],
  initialize : function(tabEl,windowEl){
    this.tabEl = $(tabEl);
    this.windowEl = $(windowEl);
    this.setOptions(arguments[2]);
    this._attachEvents();
  },
  /*
    Function: activate()
    Activates this tab.
  */
  activate : function(){
    this.tabEl.addClass(this.options.activeClass);
    this.windowEl.addClass(this.options.activeClass);
    this.fireEvent("activate",this);
  },
  /*
    Function: deactivate()
    Deactivates this tab.
  */  
  deactivate : function(){
    this.tabEl.removeClass(this.options.activeClass);
    this.windowEl.removeClass(this.options.activeClass);        
    this.fireEvent("deactivate",this);
  },
  _attachEvents : function(){
    this.tabEl.addEvent("click",function(e){e.preventDefault(); this.activate()}.bindWithEvent(this));
  },
  _isActive : function(){
     return this.tabEl.hasClass(this.options.activeClass) || this.windowEl.hasClass(this.options.activeClass);
  }
});