/*
  Class: Skyline.DraggableFileList
  Implements a basic draggable list that triggers events to do AJAX or other actions
  
  Parameters:
    draggableSelector - css query rule for draggables
    droppableSelector - css query rule for droppables.
    
  Events:
    dropped - triggered when a dragged element is dropped into a droppable container with 2 
              parameters. the draggable element and the droppable element.
    
*/
Application.DraggableFileList = new Class({
	Implements: [Events, Options],
  options : {
    draggableOpacity: 0.5
  },
  initialize : function(draggableSelector, droppableSelector,options){
    this.setOptions(options);
    this.draggableSelector = draggableSelector;
    this.droppableSelector = droppableSelector;
    
    
    this.draggables = $$(this.draggableSelector);
    this.droppables = $$(this.droppableSelector);
    
    this.draggables.each(function(item){
      item.addEvent('mousedown', this.startDrag.bindWithEvent(this,item));
      item.addEvent('click',function(ev){ this.fireEvent("selected",[ev,item]); }.bindWithEvent(this));
    }.bind(this));
  },
  startDrag : function(ev,item){
    var event = new Event(ev);
    
    // Clone item to be dragged to keep the list intact also clones content and id of the 
    // element.
    var clone = item.clone(true,true).inject(document.body);
    clone.addClass("draggableFile");
    var dimen = item.getCoordinates();
    clone.setStyles({
      visibility : "hidden",
      "float": "none", 
      left: dimen.left, 
      top: dimen.top, 
      position: "absolute"});
    
    //Set up drag events
    var fileDrag = new Drag.Move(clone, {
      snap: 5,
      droppables: this.droppables
    });
    fileDrag.dragEl = item;

    fileDrag.fileList = this;
    fileDrag.origOpacity = fileDrag.dragEl.get('opacity');
    
    fileDrag.addEvent("snap", function(){
      event.stop();
    });
    
    fileDrag.addEvents({
      "snap": this._onSnap,
      "drop": this._onDrop,
      "enter": this._onEnterDroppable,
      "leave": this._onLeaveDroppable,
      "complete": this._onComplete,
      "cancel": this._onComplete
    });
    
    // Start the drag manually
    fileDrag.start(ev);    
  },
  _onSnap : function(){
    this.element.setStyle('visibility', 'visible');
    this.dragEl.set("opacity",this.options.draggableOpacity);    
  },
  _onDrop : function(clone, droppable,event){
    if (droppable) {
      var event = new Event(event);      
      event.stop();
      this.fileList.fireEvent("dropped",[this.dragEl, droppable]);
    } 
  },
  _onEnterDroppable : function(clone,droppable){
    this.currentDrop = droppable;
    this.currentDrop.addClass("droppable");
    this.currentDrop.addClass("inside");    
  },
  _onLeaveDroppable : function(clone,droppable){
    this.currentDrop.removeClass("droppable");
    this.currentDrop.removeClass("inside");
  },
  _onComplete : function(clone){
    clone.destroy();    
    this.detach();
    if(this.currentDrop){
      this.currentDrop.removeClass("droppable");
    }
    this.dragEl.set("opacity",this.origOpacity);    
  }
});
