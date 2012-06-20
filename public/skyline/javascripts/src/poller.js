/* 
  Class: Application.Poller
  The poller periodically sends requests to the server to verify that the current
  user is still editing this page. It also handles takeover actions when another
  user takes over editing.
  
  Only ONE instance of Application.Poller can be active. Only the first
  instance will be registered into Application.Poller.current.
  
  Parameters:
  url - The URL to poll.
*/
Application.Poller = new Class({
  initialize : function(url){
    if(!url || Application.Poller.current){ return; }
    
    this.url = url;
    
    Application.Poller.current = this;
    this.poller = this.poll.periodical(5000,this);
  },
  poll : function(){
    // We don't want to use the Application.Request here because this is a background operation
    // and should not show a wait state.
    var request = new Request.JSON({url: this.url });
    request.addEvent("success",this.handlePollResponse.bind(this));
    request.get();
  },
  handlePollResponse : function(response,text){
    if(!response.current_editor){
      $clear(this.poller);
      var d  = new Skyline.Dialog();
      d.setContent(response.message);
      if(response.title){
        d.setTitle(response.title);
      }
      d.show();
    }
  },
  handleTakeOverAction : function(){
    var action = $('takeoverAction_ignore').get("checked") ? "ignore" : "new";
    var newVariantName = $('takeoverActionNewVariantName').get("value");
    
    if(action == "ignore"){
      window.location = window.location;
    } else {
      $('clone_variant').set("value","1");
      $('article_variants_attributes_1_name').set("value",newVariantName);
      tinymce.triggerSave();
      $('page_form').submit();
    }
  }  
});
Application.Poller.current = null;