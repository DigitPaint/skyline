/*
  Class: Skyline.TagSelector
  Implements a basic list of tags that interact with an inputbox  
  
  Options:
  selectedClassName - CSS classname for selected tag elements, defaults to 'selected'
  separator - The separator of the tags (default = " ")
  Events:  
*/
Skyline.TagSelector = new Class({
  Implements: [Options,Events],
  options : {
    selectedClassName: "selected",
    separator: " "
  },
  /*
    Constructor: initialize
    
    Parameters:
    inputBoxId  - the id of the textbox that will be linked to the taglist
    elementSelector - css identification of the tag element    
  */
  initialize : function(inputBoxId, elementSelector){
    this.inputBox = $(inputBoxId);      
    this.elementSelector = elementSelector;
    this.setOptions(arguments[2]);
    this.inputBox.addEvent('keyup', function(event) {this.updateActiveTags();}.bind(this));
    this.getTagNodes().each(function(item) {
      item.addEvent('click', function(event) {this.onTagClick(item);}.bind(this));
    },this);
    this.updateTagLine(this.getCurrentTags());
  },
  /*
    Function: getTagNodes
    returns all tag elements in the container
  */
  getTagNodes: function() {
    if(!$type(this.tagNodes)) { this.tagNodes = $$(this.elementSelector); }
    return this.tagNodes;
  },
  /*
    Function: getCurrentTags
    returns an array of the tags in the inputBox
  */
  getCurrentTags: function() {
    return this.inputBox.get('value').split(this.options.separator);
  },
  /*
    Function: onTagClick
    Triggered when a tag element in the container is clicked
        
    Parameters: 
    tag - tag element
  */
  onTagClick: function(tag) {
    this.toggleTag(this.tagName(tag.get('html')));
  },
  /*
    Function: toggleTag
    Fetches the currently selected tags and validates if the tag is already in collection,
    then adds of removes the tag and calls updateTagLine to update the inputbox and set the class of clicked tag
  
    Parameters: 
    tag - inner_html of clicked tag  
  */
  toggleTag: function(tag) {
    var tags = this.getCurrentTags();
    
    if (tags.contains(tag)) {
      tags = tags.filter(function(item){ return item != tag;});
    } else {
      tags.push(tag);
    }    
    this.updateTagLine(tags);
  },
  /*
    Function: updateTagLine
    Updates the inputBox with the selected tags and calls updateActiveTags to set the class of selected tags

    Parameters: 
    tags - array of selected tags
  */
  updateTagLine: function(tags) {
    this.inputBox.set('value', tags.join(this.options.separator).clean());
    this.updateActiveTags(tags);
  },
  /*
    Function: updateActiveTags
    Updates the class of the tag elements in the container
  
    Parameters: 
    tags - array of selected tags
  */
  updateActiveTags: function(tags) {
    var tags = tags;
    if(!tags){
      tags = this.getCurrentTags();
    }
    this.getTagNodes().each(function(element) {      
      if(tags.indexOf(this.tagName(element.get('html'))) != -1) {
        element.addClass(this.options.selectedClassName);       
      } else { 
        element.removeClass(this.options.selectedClassName); 
      }
    }.bind(this));        
  },
  /*
    Function: tagName
    returns a to lowercase converted converts s
  
    Parameters: 
    s - string containing the name    
  */
  tagName: function(s) {
    s = s.clean().toLowerCase();
    return s.indexOf(' ') != -1 ? ('"' + s + '"') : s;
  }
});