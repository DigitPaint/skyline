/*
  Class: Skyline.Sortable
  Create sortable lists.
*/
Skyline.Sortable = new Class({
  Implements : [Options,Events],
  options: {
    snap: 2,
    constrain: false,
    draggables : "li",
    handle : null,
    dragMarker : true,
    offsetParent : null
  },
  initialize : function(listEl){
    this.setOptions(arguments[1]);
    
    this.element = document.id(listEl);
    if(this.options.offsetParent){
      this.oParent = document.id(this.options.offsetParent);
    } else {
      this.oParent = this.element.getOffsetParent();
    }
    
    this.draggables = [];
    this.element.getChildren(this.options.draggables).each(this.addItem.bind(this));
    this.idle = true;
    
    this.boundEvents = {
      "enter" : this._onDragEnter.bind(this),
      "drop"  : this._onDrop.bind(this),
      "drag"  : this._onDrag.bind(this),
      "complete" : this._onDragComplete.bind(this),
      "cancel" : this._onDragCancel.bind(this)
    };
  },
  addItem : function(el){
    var el = document.id(el);
    var h = el;
    if(this.options.handle){
      h = el.getElement(this.options.handle);
    }
    
    h.addEvent("mousedown",this._startDrag.bindWithEvent(this,[el]));
    
    this.draggables.push(el);
  },
  _startDrag : function(event,draggable){
    if (!this.idle){ return; }
    this.idle = false;
    this.clone = this._getClone(event,draggable);
    this.draggable = draggable;
    if(this.options.dragMarker){
      this.marker = this._getDragMarker();
    }
    this.containerTop = this.element.getPosition().y;
    this.drag = new Skyline.Drag(this.clone,{
      offsetParent : this.oParent,
      droppables : this._getDroppables(draggable)
    });
    this.drag.addEvent("snap",function(){
      event.stop();
      this.clone.setStyle('visibility', 'visible');
      this.fireEvent('start', [this.draggable, this.clone]);
    }.bind(this));
    this.drag.addEvents(this.boundEvents);
    this.drag.start(event);
  },
  
  _onDragEnter : function(el,droppable){
    this.currentDrop = droppable;
    return false;    
  },
  _onDrop : function(el,droppable){
    if(this.currentDrop){
      var position = this._getDropPosition(el,this.currentDrop);
      var d = this.draggable, c = this.currentDrop;
      this.fireEvent("beforeDrop",[d,c,position]);
      this.draggable.inject(this.currentDrop,position);
      this._stopDrag();
      this.fireEvent("afterDrop",[d,c,position]);      
    } else {
      this._stopDrag();      
    }
  },
  _onDrag : function(el){
    if(!this.currentDrop || !this.marker){ return; }
    
    var position = this._getDropPosition(el,this.currentDrop);    
    this.marker.inject(this.currentDrop,position);
    this.marker.setStyles({"display": "block"});    
  },
  _onDragComplete : function(){
    this._stopDrag();
  },
  _onDragCancel : function(){
    this._stopDrag();
  },
  _stopDrag : function(){
    if(this.idle){ return; }
    
    if(this.currentDrop){ 
      this.currentDrop = null;      
    }
    
    if(this.marker){
      this.marker.destroy();
      this.marker = null;
    }
    
    this.drag.detach();    
    this.clone.destroy();
    
    this.idle = true;
    this.fireEvent('stop', this.draggable);    
  },
  _getClone : function(event, element){
    if (!this.options.clone){ return new Element('div').inject(document.body); }
    if ($type(this.options.clone) == 'function'){ return this.options.clone.call(this, event, element, this.element); }
    return element.clone(true).setStyles({
      margin: '0px',
      position: 'absolute',
      visibility: 'hidden',
      'width': element.getStyle('width')
    }).inject(this.element).position(element.getPosition(element.getOffsetParent()));
  },  
  _getDroppables : function(draggable){
    // slice(0) results in a clone.
    return this.draggables.slice(0).erase(draggable);
  },
  _getDragMarker : function(){
    if(this.marker){ return this.marker; }
    this.marker = new Element("li",{"styles" : {"z-index" : 99, "display" : "none" }, "class" : "marker"});
    this.marker.inject(document.id(document.body));
    return this.marker;
  },
  _getDropPosition : function(el,droppable){
    var h = droppable.getSize().y;
    var dropTop = droppable.getPosition(this.drag.offsetParent).y;    
    var dragTop = this.drag.mouse.now.y - this.drag.offsets.y;
    
    if((dropTop + h/2) > dragTop){
      return "before";
    } else {
      return "after";
    } 
  }    
});