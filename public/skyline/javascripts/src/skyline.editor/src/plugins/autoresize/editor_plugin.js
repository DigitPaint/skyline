/**
* $Id: editor_plugin_src.js 539 2008-01-14 19:08:58Z spocke $
*
* @author Moxiecode
* @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
*/

(function() {
	/**
	* Auto Resize
	* 
	* This plugin automatically resizes the content area to fit its content height.
	* It will retain a minimum height, which is the height of the content area when
	* it's initialized.
	*/
	tinymce.create('Skyline.Editor.plugins.AutoResizePlugin', {
		/**
		* Initializes the plugin, this will be executed after the plugin has been created.
		* This call is done before the editor instance has finished it's initialization so use the onInit event
		* of the editor instance to intercept that event.
		*
		* @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
		* @param {string} url Absolute URL to where the plugin is located.
		*/
		init : function(ed, url) {
			var t = this, oldSize = 0;

			/**
			 * This method gets executed each time the editor needs to resize.
			 */
			function resize() {
        var d = ed.getDoc(), b = d.body, de = d.documentElement, DOM = tinymce.DOM, resizeHeight = t.autoresize_min_height, myHeight, ifr;

        ifr = DOM.get(ed.id + '_ifr');
        
        if(tinymce.isWebKit){
          DOM.setStyle(ifr, 'height', "0px");
        }
        
        var parseMarginValue = function(v){
          if(tinymce.is(v, 'string')){
            if (v.indexOf('px') > -1){
              v =  parseInt(v)
            } else{
              v = 0
            }
          } 
          return v;
        }
        
        //  We have to incorporate the margin too.
        var vMargin = parseMarginValue(DOM.getStyle(d.body, "marginTop", true)) + parseMarginValue(DOM.getStyle(d.body, "marginBottom", true))
        
        // Get height differently depending on the browser used
        myHeight = tinymce.isIE ? b.scrollHeight : d.body.offsetHeight;

        // Don't make it smaller than the minimum height
        if (myHeight > t.autoresize_min_height)
        	resizeHeight = myHeight;

        // Resize content element
        if (resizeHeight !== oldSize) {
          ed.getWin().scrollTo(0,0); 
        	DOM.setStyle(ifr, 'height', (resizeHeight + vMargin) + 'px');
        	oldSize = resizeHeight;
        } else {
          if(tinymce.isWebKit){
            DOM.setStyle(ifr, 'height', (oldSize + vMargin) + "px");
          }          
        }
        
        // if we're throbbing, we'll re-throb to match the new size
        if (t.throbbing) {
        	ed.setProgressState(false);
        	ed.setProgressState(true);
        }
        
        ed.skyline_editor_height = resizeHeight;
			};

			t.editor = ed;

			// Define minimum height
      t.autoresize_min_height = 10;
      
			// Things to do when the editor is ready
			ed.onInit.add(function(ed, l) {
				// Hide scrollbars
				var b = ed.getBody()
        var tbl = tinymce.DOM.get(ed.id + '_tbl');
				
				b.style.overflowY = "hidden";
        if(tinymce.isIE){
          b.scroll = "no"  
          tinymce.DOM.setStyle(tbl, "zoom", "1");          
        }
        
        tinymce.DOM.setStyle(tbl, "table-layout", "fixed");
        tinymce.DOM.setStyle(tbl, "height", "auto");       
        
        // Resize the window onload
        var w = ed.getWin();
        if(w.addEventListener){
          w.addEventListener("load", resize, false)         
        }
			});
			
			var delayedResize = function(){
			  var nr = resize();
			  dab = tinymce.DOM.toHex(tinymce.DOM.getStyle(ed.getBody(), "backgroundColor", true));
			  if(dab != "#fffffe"){
          setTimeout(delayedResize, 50);
			  }
			};

			// Add appropriate listeners for resizing content area
			ed.onChange.add(resize);
			ed.onSetContent.add(resize);
			ed.onPaste.add(resize);
			ed.onKeyUp.add(resize);
			ed.onPostRender.add(resize);



			ed.onLoadContent.add(function(ed, l) {
        // resize();

				// Because the content area resizes when its content CSS loads,
				// and we listen to a change in background color.
				delayedResize();
				if(tinymce.isIE){
          // IE Caches too much.
				  setTimeout(delayedResize, 150);
				}
			});

			// Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand('mceExample');
			ed.addCommand('mceAutoResize', resize);
		},

		/**
		* Returns information about the plugin as a name/value array.
		* The current keys are longname, author, authorurl, infourl and version.
		*
		* @return {Object} Name/value array containing information about the plugin.
		*/
		getInfo : function() {
			return {
				longname : 'Auto Resize',
				author : 'Moxiecode Systems AB',
				authorurl : 'http://tinymce.moxiecode.com',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/autoresize',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('autoresize', Skyline.Editor.plugins.AutoResizePlugin);
})();