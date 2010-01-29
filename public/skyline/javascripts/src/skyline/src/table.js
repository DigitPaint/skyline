/*
  Class: Skyline.Table
  Create HTML tables that have:
  - Fixed headers with scrollable bodies
  - Draggable rows
  - Sortable rows
  
  Options:
    selectable - true/false (default=true)
    draggable  - true/false
    sortable   - true/false
  
  Events:
    selectedRow - Fired if a row has been selected.
    droppedRow  - 
*/

Skyline.Table = new Class({
  
  initialize : function(element){        
    this.element = $(element);    
    this.element.store("skyline.table", this);
    

    // onDomready
    window.addEvent("domready", function(){
      this._arrangeTable();    
      // this._attachEvents();
      this.resize();
    }.bind(this));
  },
  
  resize : function(){
    var s = this.element.getStyles("width", "height");    
    var styles = {}
    
    if(parseInt(s.width) > 0){
      styles.width = s.width;
    }
    if(parseInt(s.height) > 0){
      styles.height = s.height;      
    }
    
    this.wrapEl.setStyles(styles);        
    
    var widths = this._measureCells();
    this.theadEl.getElement("tr").getChildren().each(function(cell,i){
      cell.setStyles({width: widths[i]});
    });
  },
  
  _measureCells : function(){
    // Set the width to 100% 
    this.element.setStyles({width: "100%"});    
    
    var width = this.element.getSize().x;
    
    //  Hack so IE will use the correct width
    if(this.scrollEl.clientWidth < width){
      width = this.scrollEl.clientWidth;
    }
    
    this.theadEl.setStyles({width: width});
    this.element.setStyles({width: width});
    
    
    // measure inner cell sizes by adding a row with only div's
    var cells = this.element.getElement("tbody tr").getChildren();
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
    
    this.scrollEl.setStyles({
      overflow : "auto",
      overflowY : "scroll",
      height: "100%"
    });
    
    this.theadEl.setStyles({
      position : "absolute", 
      top : 0
    });
        
    this.wrapEl.setStyles({
      position : "relative",
      overflow : "hidden"
    });
    
    scroller.adopt(this.element);
    wrapper.adopt(this.theadEl);
  },
  
  
  
});
