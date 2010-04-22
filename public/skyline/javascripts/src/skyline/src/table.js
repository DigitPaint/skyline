/*
  Class: Skyline.Table
  Create HTML tables that have:
  - Fixed headers with scrollable bodies
  - Draggable rows
  - Sortable rows
  
  Options:
    selectable - true/false (default=true)
    draggable  - true/false
    sortable   - true/false, make sure you set draggable to true too!
    droppables - A css selector that has to match for an elemen to qualify as a droptarget.
  
  Events:
    selectRow       - Fired if a row has been selected.
    deselectRow     - Fired if a row has been deselected (meaning another one has been selected).
    dropRow         - Fired when a row is being dropped 
                      Passes 2 parameters: the dropped row and the target it's been dropped on.
    startDragRow    - Fired when a row is being dragged
                      Passes 2 parameters: the dragging row and the clone
    stopDragRow     - Fired when a row has stopped being dragged
                      Passes 1 parameters: the row
    enterDroppable  - Fired when the draggable row enters a droppable that matches the options.droppables selector.
    leaveDroppable  - Fired when the draggable row leaves a droppable.
    reorder         - Fired if sortable is true and the order has been changed. 
                      Passes 3 parameters: the dropped row, the adjecent row and
                      the position (before or after) relative to the adjecent row.
*/

Skyline.Table = (function(){
  var Table = new Class({
  
    Implements : [Options,Events],
  
    options : {
      selectable : true,
      dragMarker : true
    },
  
    initialize : function(element){        
      this.element = $(element);    
      this.element.store("skyline.table", this);
    
      this.setOptions(arguments[1]);
      this.ready = false;

      // onDomready
      window.addEvent("domready", function(){
        this._arrangeTable();    
        this._attachEvents();
        this.resize(this.setWidth,this.setHeight);
      }.bind(this));
    },
  
    resize : function(w,h){
      if(!this.ready){ this.setWidth = w; this.setHeight = h; return; }
      
      var styles = {}  
      var s = this.element.getStyles("width", "height");    
      
      if(w){
        styles.width = w;
      } else if(parseInt(s.width) > 0){
        styles.width = s.width;
      }
      if(h){
        styles.height = h;
      } else if(parseInt(s.height) > 0){
        styles.height = s.height;      
      }
    
      this.wrapEl.setStyles(styles);
    
      var widths = this.cellWidths = this._measureCells();
      this.theadEl.getElement("tr").getChildren().each(function(cell,i){
        cell.setStyles({width: widths[i]});
      });
    },
  
    _measureCells : function(){
      // Set the width to 100% 
      this.element.setStyles({width: "100%", height: "auto"});    
    
      this.width = this.element.getSize().x;
    
      //  Hack so IE will use the correct width
      if(this.scrollEl.clientWidth < this.width){
        this.width = this.scrollEl.clientWidth;
      }
    
      this.theadEl.setStyles({width: this.width});
      this.element.setStyles({width: this.width});
    
      // measure inner cell sizes by adding a row with only div's
      var cells = this.element.getElement("thead tr").getChildren();
      var tb = this.element.getElement("tbody");
      var tr = new Element("tr");
      tb.adopt(tr);
    
      var widths = cells.map(function(cell){
        var c = cell.clone().empty();
        var m = new Element("div", {"html" : "&nbsp;"});
        c.adopt(m);
        tr.adopt(c);
      
        return m.getSize().x;
      });
      tr.dispose();
    
      return widths;
    },
  
    _arrangeTable : function(){
      var wrapper = this.wrapEl = new Element("div");
      var scroller = this.scrollEl = new Element("div");
      wrapper.adopt(scroller);
      wrapper.replaces(this.element);
    
      this.theadEl = new Element("table", {"class" : this.element.get("class")});
      this.theadEl.adopt($(this.element.getElement("thead").clone(true)));
    
      scroller.setStyles({
        overflow : "auto",
        overflowY : "scroll",
        height: "100%",
        width: "100%"
      });
    
      this.theadEl.setStyles({
        position : "absolute", 
        top : 0
      });
        
      wrapper.setStyles({
        position : "relative",
        overflow : "hidden"
      });
    
      // Cleanup styles
      var props = ["border-left", "border-right", "border-top", "border-bottom"];
      this.wrapEl.setStyles(this.element.getStyles.apply(this.element,props));
      // wrapper.setStyle("border", "1px solid #000");
      this.element.setStyles({"border" : "none"})
    
      scroller.adopt(this.element);
      wrapper.adopt(this.theadEl);
      this.ready = true;
    },
  
    _attachEvents : function(){
      if(this.options.selectable){
        this.element.addEvent("click",this._clicked.bindWithEvent(this));
      }
      if(this.options.draggable){
        this.element.addEvent("mousedown", this._startDrag.bindWithEvent(this));
        
        // Make sure IE doesn't call dragstart
        if(Browser.Engine.trident){
          this.scrollEl.ondragstart = function(){ return false; };
        }
      }
    },
  
    // Event handling
  
    _clicked : function(event){
      var target = $(event.target);
    
      var row = target.getParent("tr");
      if(row){
        if(this.selectedRow){
          this.fireEvent("deselectRow",[this.selectedRow,event])
        }
        this.selectedRow = row;
        this.fireEvent("selectRow",[row,event]);
      }
    },
    
    _startDrag : function(event){
      var target = $(event.target);
      var row = target.getParent("tr");
      if(!row){ return; }
      
      this.drag = new RowDrag(row,this,{
        offsetParent : this.scrollEl,
        orderable : this.options.orderable,
        dragMarker : this.options.dragMarker
      });
      
      this.drag.addEvents({
        "snap" : function(){ event.stop(); }
      });

      this.drag.start(event);      
    }
  
  });
  
  // ===========
  // = RowDrag =
  // ===========
  
  var RowDrag = new Class({
    // Extends: Drag.Move,
    Extends: Skyline.Drag,    
    options: {
      snap: 5, 
      droppables: [],
      opacity: 0.5,
      checkDroppables: false,
      dragMarker: true
    },    
    initialize : function(element,table){
      this.dragEl = element;
      this.setOptions(arguments[2]);
      
      this.table = table || this.dragEl.getParent("table").retrieve("skyline.table");
      
      this.options.droppables = this.getDroppables();

      // this.origOpacity = this.dragEl.get('opacity');
      this.clone = this.createClone(this.dragEl);
      
      if(this.options.dragMarker){
        this.marker = this.createDragMarker();
      }
      
      this.parent(this.clone);

      this.addEvents({
        "snap" : this._onSnap,
        "complete" : this._onDone,
        "cancel" : this._onDone,
        "drop" : this._onDrop,
        "drag" : this._onDrag
      });      
    },
    getDroppables : function(){
      
    },
    // Clone this.dragEl into a new Table.
    createClone : function(){
      var t = this.table.element.get("class")
      var clone = new Element("table", { "class" : t + " clone" });
      var tb = new Element("tbody");
      var row = this.dragEl.clone(true);
      var self = this;
      
      row.getChildren().each(function(cell,i){
        cell.setStyles({"width" : self.table.cellWidths[i]});
      });
      clone.adopt(tb);
      tb.adopt(row);
      
      // clone.inject(this.table.element,"after");
      clone.inject($(document.body));
      
      clone.setStyles({
        position: "absolute",
        width: self.table.element.getSize().x,
        display: "none"
      });
      var pos = this.dragEl.getPosition();
      var scr = self.table.scrollEl.getScroll();
      pos.x += scr.x;
      pos.y += scr.y;
      clone.setPosition(pos);
      
      self = null;
      return clone;
    },
    createDragMarker : function(){
      var marker = new Element("div",{
        "styles" : {
          "position" : "absolute", 
          "z-index" : 99, 
          "display" : "none",
          "width" : this.table.width,
          "left" : this.table.element.getPosition().x
        }, 
        "class" : "tablemarker"
      });
      marker.inject($(document.body));
      return marker;      
    },
    // Events
    _onSnap : function(){
      this.clone.setStyle("display","block");
      this.table.fireEvent("startDragRow", [this.dragEl, this.clone]);
    },
    _onDrag : function(clone, event){
      if(!this.table.options.sortable && !this.table.options.draggable){
        return false
      }
      
      var el = this._getTargetFromEvent(clone,event);
      if(!el){ return }
      
      // Sortable
      if(this.table.options.sortable){
        var row = el.getParent("tr");
        if(row && row.getParent("table") == this.table.element && row != this.dragEl){
          if(this.marker){
            this.marker.setStyles({"top" : this._getSortPosition(row)[1], "display" : "block"});
          }
        } else {
          if(this.marker){
            this.marker.setStyle("display", "none");
          }
        }        
      }
      
      // Drag elsewhere
      if(this.table.options.draggable){
        if(this.prevTarget != el){
          var drop = this._getDroppable(el);
          if(drop){
            if(this.lastDrop != drop){
              if(this.lastDrop){
                this.table.fireEvent("leaveDroppable", [this.dragEl, this.lastDrop]);
              }
              this.table.fireEvent("enterDroppable", [this.dragEl, drop]);  
              this.lastDrop = drop;
            }
          } else if(this.lastDrop != null){
            this.table.fireEvent("leaveDroppable", [this.dragEl, this.lastDrop]);
            this.lastDrop = null;
          }
        } 
        this.prevTarget = el;        
      }
      
    },
    // droppable is always empty, because we don't use it
    _onDrop : function(clone, droppable, event){
      if(this.table.options.draggable){
        var drop = this._getDroppable(this._getTargetFromEvent(clone,event));
        if(drop){
          this.table.fireEvent("dropRow", [this.dragEl,drop]);
        }
      }      
      if(this.table.options.sortable){
        var el = this._getTargetFromEvent(clone,event);
        var row = el.getParent("tr");
        if(row && row.getParent("table") == this.table.element && row != this.dragEl){
          var pos = this._getSortPosition(row);
          this.dragEl.inject(row,pos[0]);
          this.table.fireEvent("reorder", [this.dragEl,row,pos[0]]);
        }
      }
    },
    _getDroppable : function(el){
      return (el.match(this.table.options.droppables) && el) || el.getParent(this.table.options.droppables);
    },
    _getSortPosition : function(row){
      var h = row.getSize().y;
      var t = row.getPosition().y + this.scroll.y;
      var m = this.mouse.now.y;
      if((t + h/2) > m){
        return ["before",t];
      } else {
        return ["after", t + h];
      }
    },
    _getTargetFromEvent : function(clone, event){
      var x,y;
      
      if(Browser.Engine.presto || Browser.Engine.webkit){
        x = event.page.x;
        y = event.page.y;       
      } else {
        x = event.client.x;
        y = event.client.y;               
      }
      
      clone.setStyle("display", "none");
      var el = document.elementFromPoint(x,y);
      clone.setStyle("display", "");
      
      if(el){
        // Opera 9 detects a textnode so we take it's parentNode
        if (el.nodeType == 3) { el = el.parentNode; }
    
        return $(el);
      } else {
        return null;
      }
    },
    _onDone : function(){
      this.clone.destroy();
      if(this.marker){ this.marker.destroy(); }
      this.table.fireEvent("stopDragRow", this.dragEl);      
    }
    
  });
  
  return Table;
})();
