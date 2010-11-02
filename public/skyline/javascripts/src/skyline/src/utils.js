/*
  Structure: Skyline.Utils
*/
Skyline.Utils = {
  /*
    Function: getJsLocation(filename)
    Find the url, filename and parent url of "filename"
    
    Returns:
    A Hash with the following keys:
    filename - The filename you passed in
    url - The full SRC/url of the filename
    base - The parent url of filename
  */
  getJsLocation : function(filename){
    var sElements = document.getElementsByTagName("SCRIPT");
    var r = {};
  	for (var i=0; i<sElements.length; i++) {
  		src = sElements[i].src;
  		if (src && src.indexOf(filename) != -1) {

  			r.filename = filename;
  			r.base = src.substring(0, src.lastIndexOf('/'));
        r.url = src;

  			if ((p = src.indexOf('?')) != -1){
  				r.query = src.substring(p + 1);
  			}
  			return r;
  		}
  	}

  }
};