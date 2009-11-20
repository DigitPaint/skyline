Application.Message = new Class({
  Implements : [Options],
  options : {
    area : "messageArea",
    type: "success"
  },
  initialize : function(msg){
    this.setOptions(arguments[1]);
    this.areaEl = $(this.options.area);
    this.message = msg;
    if(!this.areaEl){
      throw("Can't find options.area.");
    }

    this.add();
    this.setupArea();
    this.render();
  },
  add : function(){
    Application.Message.all.push(this);    
  },  
  render : function(){
    this.element = new Element("div", {"class" : this.options.type, "html" : this.message});
    this.element.inject(this.containerEl,"bottom");
    this.postRender();
  },
  
  postRender : function(){
    var l;
    if(l = this.areaEl.retrieve("skyline.layout")){
      l.parent.setup();
    }    
  },
  
  setupArea : function(){
    if(this.areaEl){
      this.containerEl = this.areaEl.getElement(".messages");
      if(!this.containerEl){
        this.containerEl = new Element("div", {"class": "messages"});
        this.areaEl.adopt(this.containerEl);
      }
      
    }
  }
});

Application.Message.all = $A([]);

Application.Notification = new Class({
  Extends : Application.Message,
  add : function(){
    Application.Notification.all.push(this);
    setTimeout(this.hide.bind(this),5000);
  },
  hide : function(){
    this.element.dispose();
    this.postRender();
  }
});

Application.Notification.all = $A([]);