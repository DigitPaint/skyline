/*
  Function: getSequence
  Extract's id's from all elements that match selector and maps them with getId();
  
  Parameters:
  selector - The selector to select elements with
  
  Returns:
  Array - Array of id's
*/
Application.getSequence = function(selector){
  return $$(selector).map(function(e){
    return Application.getId(e.get("id"));
  });
};

/*
 Function: getId
 Extract an id from a string formatted like "abderfafadfadf_2" or "babab-13"
 
 Parameters:
 str - String to extract id\s from in the format "abcdef_ID"
 
 Returns:
 String - The extarcted id
*/
Application.getId = function(str){
  return str.replace(/^.*[_-]/,"");
};

/*
  Function: addOddEven
  Adds "odd" and "even" classes to all elements matching selector
  
  Parameters:
  parent - The parent element.
  selector - The selector to select elements with, defaults to parant.getChildren() [OPTIONAL]
*/
Application.addOddEven = function(parent,selector){
	var parent = $(parent), counter = 0, elements = parent.getChildren();
	if(selector){
	  elements = parent.getElements(selector);
	}

	elements.each(function(el,i){
		if(!(el.hasClass("odd") || el.hasClass("even"))){ return; }
		counter += 1;
		el.removeClass("odd");
		el.removeClass("even");
		el.addClass((counter+1) % 2 === 0 ? "odd" : "even");
	});
};

/*
  Function: rubyClassToCssClass
  Converst a ruby class name with module (Skyline::PageVersion) to pageVersion
  
  Parameters:
  rubyclass - A string with the rubyclass name in it
*/
Application.rubyClassToCssClass = function(rubyclass){
  return  rubyclass.replace(/.+::(.+)/,"$1").replace(/^./,function(m){return m.toLowerCase(); });
}

/*
  Function: normalizeUrlPart
  Normalize a string into an urlPart: a string like "a b D !?" will become "a_b_d"
  
  Parameters:
  string - String to convert
  glue - The glue to use as spaces [OPTIONAL], defaults to "_"
*/
Application.normalizeUrlPart = function(string){
  var glue = arguments[1] || "_";
  return string.toLowerCase().replace(/[^a-z0-9]+/g," ").trim().replace(/ /g,glue)
}

Application.toggleSpin = function(element,message){
  var key = "application.spinner";
	var element = $(element);
	var spinner = element.retrieve(key);
	if(spinner){
		spinner.dispose();
		element.setStyle("display",	element.retrieve(key + ".origDisplay"));
		element.store(key,null);		
		element.store(key + ".origDisplay",null);				
	} else {
		spinner = new Element("span", {'class': 'spinner', "html" : message});
		element.store(key,spinner);
		element.inject(spinner,"before");
		element.store(key + ".origDisplay",element.getStyle("display"));
		element.setStyle("display","none");
	}
};

/*
  Function: sanitizeUrl
  Prefixes the given url with http:// if the url:
    -     doesn't start with a protocol
    - AND doesn't start with a /
    - AND doesn't start with a #
    
  Parameters:
  string - url to sanitize
*/
Application.sanitizeUrl = function(url){
  if (!(/^[a-z][a-z0-9\+\-\.]*:/.test(url)) && !(/^\//.test(url)) && !(/^#/.test(url))) {
    return "http://" + url;
  }
  return url;
}