/*
  Class: Skyline.Menu
*/
Skyline.Menu = new Class({
  initialize : function(el){
    this.listEl = $(el);
    this.storeKey = "skyline.menu:current";
    this.menus = this.listEl.getElements("ul");
    var t = this;

    this.listEl.getChildren("li").each(function(li){
      li.getFirst().addEvent("click",function(event){
        t.openLi(event,li,t.listEl);
      });
    });  
    
    this.menus.each(function(ul){
      ul.getChildren("li").each(function(li){
        li.addEvent("mouseenter", t.openLi.bindWithEvent(t,[li,ul]));
      });
    });
    
    document.addEvent("click",function(event){
      var menus = t.menus.combine([t.listEl]);
      menus.each(function(ul){
        var act = ul.retrieve(t.storeKey);
        if(act){
          act.removeClass("open");
        }
        ul.eliminate(t.storeKey);
      });
    }.bind(this))
    
  },
  openLi : function(event,el,parent){
    if(event){event.stopPropagation();}
    var childList, childAct, act = parent.retrieve(this.storeKey);
    
    if(childList = el.getElement("ul")){
      if(childAct = childList.retrieve(this.storeKey)){
        childAct.removeClass("open");
        childList.eliminate(this.storeKey);
      }
    }    

    if(act == el){
      return;
    }
    
    if(act){
      act.removeClass("open");
    }

    parent.store(this.storeKey,el);    
    el.addClass("open");
  }  
});