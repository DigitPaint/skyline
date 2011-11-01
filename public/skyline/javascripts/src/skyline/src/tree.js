/*
  Class: Skyline.Tree
  Implements a basic sorting tree that triggers a range of
  events to do AJAX (or other) actions.
  
  Events:
  
  collapse  - Triggered when a branch is colapsed by user, passes the collapsed branch (LI)
  expand    - Triggered when a branch is expanded by user, passes the expanded branch (LI)
  move      - Triggered when a branch is moved, passes the moved branch (LI), 
              the new parent (LI), the new position (integer, begins with 0)
  select    - Triggered when a node is selected, passes the selected node (A)
  
  Options:
  
  fixedRootNodes   - Only allow the default root nodes to exist, no new root nodes
                     can be created by dragging. (default=false)
  orderable        - Wether or not the nodes are orderable (default=true)
  orderBy          - If a drop is done inside a node, this order function can determine where
                     to place the new node. Must be a function (function(draggedLi,li){})
                     accepting two parameters, both LI nodes and 
                     return true if draggedLi should be after li
                     return false if draggedLi should be before li
  dragMarker       - Wether or not to show a drag marker for the dropposition (default=true)
  draggable        - Wether or not the tree is reordable. (default=true)
  draggableOpacity - The opacity of the subtree in the tree whil it's ghos is being dragged (default=0.5)
  offsetParent     - The offsetParent to use when the tree is in a scrollable div (default = this.containerEl.getOffsetParent())
  
*/
Skyline.Tree = new Class({
  Implements: [Options,Events],
  options : {
    fixedRootNodes: false,
    orderable: true,
    orderBy : null,
    draggable: true,
    dragMarker: true,
    draggableOpacity : 0.5,
    offsetParent : null
  },
  initialize : function(elementId){
    this.containerId = $(elementId).get('id');
    this.setOptions(arguments[1]);
    this.reload();
    
    // Register ourselves with the container
    this.containerEl.store("skyline.tree",this);        
  },
  /*
    Function: reload
    Reloads the tree after it has been updated by AJAX
  */
  reload : function(){
    this.containerEl = $(this.containerId);
    this.rootList = this.containerEl.getElement("ul");
    if(this.options.offsetParent){
      this.oParent = $(this.options.offsetParent);
    } else {
      this.oParent = this.containerEl;
    }
    this.idle = true;
    this.attachEvents();
    this.initNodes();
  },
  /* 
    Function: collapse
    Collapse the full tree
  
    Parameters:
    level - Collapses the tree until level X (does not expand previously closed nodes) [OPTIONAL]
  */ 
  collapse : function(){    
    var collapseUntil = 0;
    if(arguments.length > 0){ collapseUntil = arguments[0]; }
    this.rootList.getElements(this.levelSelector(collapseUntil)).addClass("closed").removeClass("open");
  },
  /* 
    Function: expand
    Expand the full tree
  
    Parameters:
    level - Expands the tree until level X, zero for expand all. [OPTIONAL] 
  */ 
  expand : function(){
    var expandUntil = 0;
    if(arguments.length > 0){ expandUntil = arguments[0]; }
    this.rootList.getElements("li.hasChildren").addClass("open").removeClass("closed");
    this.collapse(expandUntil);
  },
  // INTERNAL METHODS
  levelSelector : function(level){
    var selector = "li.hasChildren";  
    for(var i = level; i--; i === 0){
      selector = selector + " li.hasChildren";
    };    
    return selector;
  },  
  startDrag : function(ev){
    if(!this.idle){ return; }
    
    var theEvent = new Event(ev);
    
    var element;
    var target = $(theEvent.target);
    if(target.get("tag") == "a" || target.getParent("a")){
      element = target.getParent("li");
    } else {
      return;
    }
    
    if(this.options.fixedRootNodes && this.rootNodes.indexOf(element) > -1){
      return
    }
    
    this.idle = false;
    
    this.drag = new Skyline.Tree.SubTreeDrag(element,this.rootList,{
      offsetParent : this.oParent,
      orderable : this.options.orderable,
      dragMarker : this.options.dragMarker,
      orderBy : this.options.orderBy,
      fixedRootNodes : this.options.fixedRootNodes,
      rootNodes : this.rootNodes
    });
    this.drag.addEvents({
      "snap" : function(){ theEvent.stop(); },
      "stop" : this.onStopDragSubtree.bind(this),
      "move" : this.onMoveSubtree.bind(this)
    });
    
    this.drag.start(ev);
  },
  onStopDragSubtree : function(){
    this.idle = true;
    this.redraw();
  }, 
  onMoveSubtree : function(draggableEl){
    var pos = draggableEl.getParent().getChildren().indexOf(draggableEl);
    var parentEl = draggableEl.getParents("li")[0];
    // console.info("Moving Subtree: " + draggableEl.get("id") + " into " + parentEl.get("id") + " at " + pos);
    this.fireEvent("move",[draggableEl,parentEl,pos]);
  },   
  redraw : function(){
    this.containerEl.getElements("li").each(function(el){
      el.removeClass("last");
      if(el.getElement("ul li")){
        el.addClass("hasChildren");
      } else {
        var ul = el.getElement("ul");
        if(ul){ ul.addClass("empty"); }
        el.removeClass("hasChildren");
        el.removeClass("open");
      }
    });
    this.containerEl.getElements("li:last-child").addClass("last");
  },
  initNodes : function(){
    this.redraw();
    this.selectedNode = this.containerEl.getElement("a.selected");
    this.rootNodes = $A(this.rootList.childNodes).filter(function(node){ return node.nodeType == 1 && node.tagName == "LI" });
  },
  attachEvents : function(){
    
    if(this.options.draggable){
      this.containerEl.addEvent("mousedown",this.startDrag.bindWithEvent(this));
    }
    
    this.containerEl.addEvent("click",this.click.bindWithEvent(this));
    
    // Make sure IE doesn't call dragstart
    if(Browser.Engine.trident){
      this.containerEl.ondragstart = function(){ return false; };
    }
  },
  click : function(ev){
    var event = new Event(ev), parents;
    var target = $(event.target);
    if(target.get("tag") == "li" && target.hasClass("hasChildren")){
      // Collapse / Expand branch
      event.stop();
      if(!target.hasClass("closed")){
        this.collapseNode(event,target);
      } else {
        this.expandNode(event,target);       
      }
    } else if(target.get("tag") == "a"){
      // Select a node
      this.selectNode(event,target);
    } else {
      parents = target.getParents("a")
      if(parents[0]){
        this.selectNode(event,parents[0]);
      }
    }
  },
  selectNode: function(event,target) {
    if(this.selectedNode){
      this.selectedNode.removeClass("selected");
    }
    this.selectedNode = target;
    this.selectedNode.addClass("selected");   
    this.fireEvent("select",[event,target]);
  },
  expandNode: function(event,target) {
    target.removeClass("closed");
    target.addClass("open");
    this.fireEvent("expand",[event,target]);
  },
  collapseNode: function(event,target) {
    target.removeClass("open");
    target.addClass("closed");    
    
    if (target.getElement(".selected")){
      this.selectNode(event,target.getElement("a"));
    }
    
    this.fireEvent("collapse",[event,target]);
  }
});

Skyline.Tree.SubTreeDrag = new Class({
  Extends: Skyline.Drag,
  options: {
    snap: 5, 
    droppables: [],
    opacity: 0.5
  },
  initialize : function(element,rootList){
    this.rootListEl = rootList;
    this.dragEl = element;
    this.setOptions(arguments[2]);
    this.options.droppables = this.getDroppables();
        
    this.origOpacity = this.dragEl.get('opacity');
    this.clone = this.createClone(this.dragEl);
    if(this.options.dragMarker){    
      this.marker = this.createDragMarker();
    }
    if(this.options.rootNodes){
      this.rootNodes = this.options.rootNodes;
    }
    this.containerTop = this.rootListEl.getParent().getPosition().y;
    
    this.parent(this.clone);
    
    this.addEvents({
      "snap" : this._onSnap,
      "complete" : this.doneDragging,
      "cancel" : this.doneDragging,
      "drop" : this._onDrop,
      "drag" : this._onDrag,
      "enter" : this._onEnter,
      "leave" : this._onLeave
    });
  },
  doneDragging : function(){
    this.detach();
    this.cleanupCurrentDrop();
    this.dragEl.set("opacity",this.origOpacity);
    this.clone.destroy();
    this.fireEvent("stop");
  },
  createClone: function(element){
    return element.clone(true).setStyles({
      'margin': '0px',
      'position': 'absolute',
      'visibility': 'hidden',
      'width': element.getStyle('width')
    }).inject(this.rootListEl).position(element.getPosition(this.rootListEl));
  },
  createDragMarker : function(){
    var marker = new Element("div",{"styles" : {"position" : "absolute", "z-index" : 99, "display" : "none" }, "class" : "treemarker"});
    marker.inject($(document.body));
    return marker;
  },
  determineDropPosition : function(el,droppable){
    if(this.options.fixedRootNodes && this.rootNodes.indexOf(droppable) > -1){ return "inside" }
    if(!this.options.orderable){ return "inside";}
    
    // See if this is a single node or one that has a subtree.
    // Closed subtrees also count as single nodes. If it's NOT single node
    // you can't drop below the node (it would give a weird result)
    var singleNode = droppable.hasClass("closed") || !droppable.hasClass("hasChildren");
    
    // Take first child to determine droppable position, the LI element
    // can be higher due to subtrees.
    var droppable = droppable.getFirst();
    
    var h = droppable.getSize().y;
    var dropTop = droppable.getPosition(this.offsetParent).y;
    var dragTop = this.mouse.now.y - this.offsets.y;
    
        
    if((dropTop + h/4) > dragTop){
      return "before";
    } else {
      if(!singleNode){ return "inside"; }
      if((dropTop + h * 3/4) < dragTop){
        return "after";
      } else {
        return "inside";
      }
    }
  },    
  getDroppables : function(){
    var allLiElements;
    
    allLiElements = this.rootListEl.getElements("li");
    
    // remove the clone
    allLiElements.erase(this.clone);    
    // remove the element
    allLiElements.erase(this.dragEl);
    // remove the elements elements
    this.dragEl.getElements("li").each(function(el){allLiElements.erase(el);});
        
    return allLiElements;
  },
  getSubTreeOf: function(nodeElement){
    var ul = nodeElement.getChildren("ul")[0];
    if(!ul){
      ul = new Element("ul");
      ul.inject(nodeElement,"bottom");
    }
    return ul;
  },
  cleanupCurrentDrop : function(){
    if(!this.currentDrop){ return; }
    this.currentDrop.removeClass("droppable");   
    if(this.marker){
      this.currentDrop.removeClass("inside");
      this.currentDrop.removeClass("before");
      this.currentDrop.removeClass("after");      
      this.marker.setStyle("display","none");
    }
    this.currentDrop = null;    
  },
  _onSnap : function(el){
    // Event.stop(); // We cought the event manually, don't let it bubble!
    this.clone.setStyle('visibility', 'visible');
    this.dragEl.set('opacity', this.options.opacity || 0);
    return false;
  },
  _onDrop : function(ghostEl,droppable){
    if(droppable){
      var position = this.determineDropPosition(ghostEl,droppable); 
      
      if(position == "before" || position == "after"){
        this.dragEl.inject(droppable, position);
      } else {
        var subtree = this.getSubTreeOf(droppable);
        var injected = false;
        //  Do the ordering.
        if(this.options.orderBy){
          var elements = subtree.getChildren("li");
          injected = elements.some(function(el){
            if(!this.options.orderBy(this.dragEl,el)){
              this.dragEl.inject(el,"before");
              return true;
            }
          }.bind(this));
        }
        if(!injected){
          this.dragEl.inject(subtree,"bottom");
        }
        subtree.removeClass("empty");
      }
      this.fireEvent("move",this.dragEl);
    }
  },
  _onDrag : function(el){
    if(!this.currentDrop){ return; }
    if(!this.marker){
      this.currentDrop.addClass("inside");
      return;
    }
    
    var pos = this.determineDropPosition(el,this.currentDrop);
    var coord = this.currentDrop.getCoordinates(this.offsetParent);
    
    var top;
    if(pos == "before"){
      top = coord.top;
    } else { // Inside or After      
      top = coord.bottom;
    }
    top += this.offsets.y;
    
    this.currentDrop.removeClass("inside");
    this.currentDrop.removeClass("before"); 
    this.currentDrop.removeClass("after");     
    this.currentDrop.addClass(pos);    
    this.marker.setStyles({"left" : coord.left, "top" : top, "display": "block"});
    this.marker.set("class","treemarker " + pos);
  },
  _onEnter : function(el,droppable){
    this.currentDrop = droppable;
    this.currentDrop.addClass("droppable");
    return false;
  },
  _onLeave : function(el,droppable){
    this.cleanupCurrentDrop();
    return false;    
  }
  
});
