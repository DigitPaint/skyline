/* 
  Class: Application.Request
  Extends: Request
  
  Application.Request globally sets certain waiting indicators.
*/

(function($){
  var cursorWait = new Class({
    addWaitEvents : function(){
      this.addEvent("request", this._startWaiting);
      this.addEvent("complete", this._stopWaiting);         
    },
    _startWaiting : function(){
      $(document.body).addClass("cursor-wait");
    },
    _stopWaiting : function(){
      $(document.body).removeClass("cursor-wait");    
    }    
  });
  
  window.Application.Request = new Class({
    Extends : Request,
    Implements : [cursorWait],
    initialize : function(){
      this.parent.apply(this, arguments);
      this.addWaitEvents();
    }    
  });

  window.Application.Request.HTML = new Class({
    Extends : Request.HTML,
    Implements : [cursorWait],
    initialize : function(){
      this.parent.apply(this, arguments);
      this.addWaitEvents();
    }    
  });

  
})(document.id);
