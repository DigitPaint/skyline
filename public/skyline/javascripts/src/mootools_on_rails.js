/* 
  Class: Element
  Extensions to the Element class to make certain actions easier (replace and replaceHTML) to achieve
  in MooTools.
  
*/


if ('outerHTML' in document.documentElement) {
  Element.HtmlToDom = function(element,content){
    var div = new Element('div');
    div.set("html",content);
    return $A(div.childNodes);    
  };
} else {
  Element.HtmlToDom = function(element,content) {
    var range = element.ownerDocument.createRange();
    range.selectNode(element);
    return $A([range.createContextualFragment(content.stripScripts())]);
  };  
};

Element.implement({
	replace: function(content) {
	  var scripts = "";
	  var nc = content.stripScripts(function(s){ scripts = s; });
	  
    if ('outerHTML' in document.documentElement) {	  
      this.outerHTML = nc;
  	} else {
  		var el = Element.HtmlToDom(this,nc)[0];
  		this.parentNode.replaceChild(el, this);	  
  	}
  	$exec(scripts);
	},
	
	replaceHTML: function(content) {		
		this.set('html', content);
		content.stripScripts(true);
	},	
	
	append: function(position, content) {
	  var scripts = "";
	  var nc = content.stripScripts(function(s){ scripts = s; });
    var els = Element.HtmlToDom(this,nc);
    if (position == 'top' || position == 'after'){ els.reverse(); };
    els.each(function(el){
      Element.inject(el,this,position);
    }.bind(this));
    $exec(scripts);
	},
	
	appendTop: function(content) { this.append('top', content); },
	
	appendBottom: function(content) { this.append('bottom', content); },
	
	appendAfter: function(content) { this.append('after', content); },
	
	appendBefore: function(content) { this.append('before', content); }	
});	

