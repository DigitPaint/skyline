(function(){
  /*
    Class: Element
  */
  var EventDelegation = {
    /*
      Function: addComponentEvent
      Allows setting of events on components when the component hasn't been created yet. This only
      works with components that will be linked to a specific DOM node. The component
      is responsible for collecting the events through collectComponentEvents. If the component
      already exists, it will just add the event to the component.
      
      Parameters:
      componentName - The name of the component ("skyline.layout" for instance).
      eventName     - The name of the event.
      callback      - The callback function for the event.
    */
    addComponentEvent : function(componentName,eventName, callback){
      var c, d, e;
      if(c = this.retrieve(componentName)){
        c.addEvent(eventName,callback);
      } else {
        d = this.retrieve(componentName + ".events");
        if(!d){ d = []; }
        e = {};
        e[eventName] = callback;
        d.push(e);
        this.store(componentName + ".events", d);
      }
    },
    /*
      Function: collectComponentEvents
      Collect all events set for a component and move them to the passed component.
      
      Parameters:
      componentName - Name of the component
      component     - The component that will now receive the events
    */
    collectComponentEvents : function(componentName,component){
      var d = this.retrieve(componentName + ".events");
      if(d){
        for(var i = 0; i < d.length; i++){
          component.addEvents(d[i]);
        }
        this.eliminate(componentName + ".events");
      }
    }
  };
  Element.implement(EventDelegation);
})();