/*
  Class: Skyline.Drag
  
  Extends: 
  Drag.Move
*/
Skyline.Drag = new Class({
  Extends : Drag.Move,
	actualDrag: function(event){
		if (this.options.preventDefault) event.preventDefault();
		this.mouse.now = event.page;
		for (var z in this.options.modifiers){
			if (!this.options.modifiers[z]) continue;
      // this.mouse.now[z] -= this.scroll[z];
			this.value.now[z] = this.mouse.now[z] - this.mouse.pos[z] + this.scroll[z];
			if (this.options.invert) this.value.now[z] *= -1;
			if (this.options.limit && this.limit[z]){
				if ($chk(this.limit[z][1]) && (this.value.now[z] > this.limit[z][1])){
					this.value.now[z] = this.limit[z][1];
				} else if ($chk(this.limit[z][0]) && (this.value.now[z] < this.limit[z][0])){
					this.value.now[z] = this.limit[z][0];
				}
			}
			if (this.options.grid[z]) this.value.now[z] -= ((this.value.now[z] - (this.limit[z][0]||0)) % this.options.grid[z]);
			if (this.options.style) this.element.setStyle(this.options.modifiers[z], this.value.now[z]  + this.options.unit);
			else this.element[this.options.modifiers[z]] = this.value.now[z] ;
		}
		this.fireEvent('drag', [this.element, event]);
	},  
  drag : function(event){
    this.scroll = this.offsetParent.getScroll();    
    this.actualDrag(event);
    if (this.options.checkDroppables && this.droppables.length) this.checkDroppables();
  },
  checkAgainst: function(el, i){
    el = (this.positions) ? this.positions[i] : el.getCoordinates(this.offsetParent);

    var now = this.mouse.now;
    var x = (isNaN(now.x) ? 0 : now.x) - this.offsets.x;
    var y = (isNaN(now.y) ? 0 : now.y) - this.offsets.y;

    return (x > el.left && x < el.right && y < el.bottom && y > el.top);
  },
 
  checkDroppables: function(){
    var overed = this.droppables.filter(this.checkAgainst, this).getLast();
    if (this.overed != overed){
      if (this.overed) this.fireEvent('leave', [this.element, this.overed]);
      if (overed) this.fireEvent('enter', [this.element, overed]);
      this.overed = overed;
    }
  },
  start: function(event){
    this.parent(event);
    var realOffsetParent = this.element.getOffsetParent();
    this.offsetParent = $(this.options.offsetParent) || realOffsetParent;
    this.offsets = this.offsetParent.getPosition();
    this.scroll = this.offsetParent.getScroll();      
    
    for (var z in this.options.modifiers){
      if (!this.options.modifiers[z]) continue;
      this.mouse.pos[z] = event.page[z] - this.value.now[z];
      if(this.offsetParent != realOffsetParent){
        this.mouse.pos[z] += this.scroll[z];
      }
    }
  }
});