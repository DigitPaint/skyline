/*
  Class: Skyline.FieldReplicator
  Replicates values of the source field on the keyup and change event
  
  If the target is a form field it will only set it
  if the target doesn't have an own value set (determined by the "keyup" event)

  Options:
  events      - The events on the source that will trigger replication ["keyup","change"]
  translator  - Function to send the value to before replicating [function(value){return value;}]
  stopOnTargetChange - Stop if the target is changed [true]  
*/
Skyline.FieldReplicator = new Class({
  Implements : [Options],
  options : {
    events : ["keyup","change","blur"],
    translator : function(value){return value; },
    stopOnTargetChange: true
  },
  initialize : function(source,target){
    this.source = $(source);
    this.target = $(target);
    if(this.target.tagName.toLowerCase().match(/^input|textarea$/)){
      this.setMethod = this.updateField.bind(this);
      if(this.target.get("value") !== "" && this.target.get("value") != this.source.get("value")){
        return;
      }
    } else {
      this.setMethod = this.updateElement.bind(this);
    }
    
    this.setOptions(arguments[2]);
    
    $A(this.options.events).each(function(eventName){
      this.source.addEvent(eventName,this.replicate.bind(this));
    }.bind(this));
    
    if(this.options.stopOnTargetChange){
      this.target.addEvent("keyup",function(){
        if(this.target.get("value") != this.options.translator(this.source.get("value"))){
          this.stop = true;          
        }
      }.bind(this));
    }
  },
  replicate : function(){
    if(this.stop){ return; }
    this.setMethod(this.options.translator(this.source.get("value")));
  },
  updateField : function(value){
    this.target.set("value",value);
  },
  updateElement : function(value){
    this.target.update(value);
  }
});