/**
 * $Id: Toolbar.js 706 2008-03-11 20:38:31Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

/**#@+
 * @class This class is used to create toolbars a toolbar is a container for other controls like buttons etc.
 * @member tinymce.ui.Toolbar
 * @base tinymce.ui.Container
 */
tinymce.create('Skyline.Editor.Toolbar:tinymce.ui.Container', {
	/**#@+
	 * @method
	 */
	 
	 setDisabled : function(s){
	   var newState = s
	   this.parent(s);
	   tinymce.each(this.controls,function(c){
	     if(s){
  	     c.origDisabledState = c.disabled;
  	     c.setDisabled(true);
  	   } else {
  	     c.setDisabled(c.origDisabledState);
  	   }
	     
	   });
	 },

   destroy : function(){
     this.parent();
     tinymce.DOM.remove(this.id);
   },

	/**
	 * Renders the toolbar as a HTML string. This method is much faster than using the DOM and when
	 * creating a whole toolbar with buttons it does make a lot of difference.
	 *
	 * @return {String} HTML for the toolbar control.
	 */
	renderHTML : function() {
		var t = this, h = '', c, co, dom = tinymce.DOM, s = t.settings, i, pr, nx, cl;

		cl = t.controls;
		for (i=0; i<cl.length; i++) {
			// Get current control, prev control, next control and if the control is a list box or not
			co = cl[i];
			pr = cl[i - 1];
			nx = cl[i + 1];

			// Add toolbar start
			if (i === 0) {
				c = 'mceToolbarStart';

				if (co.Button)
					c += ' mceToolbarStartButton';
				else if (co.SplitButton)
					c += ' mceToolbarStartSplitButton';
				else if (co.ListBox)
					c += ' mceToolbarStartListBox';

				h += dom.createHTML('div', {'class' : c}, dom.createHTML('span', null, '<!-- IE -->'));
			}

			// Add toolbar end before list box and after the previous button
			// This is to fix the o2k7 editor skins
			if (pr && co.ListBox) {
				if (pr.Button || pr.SplitButton)
					h += dom.createHTML('div', {'class' : 'mceToolbarEnd'}, dom.createHTML('span', null, '<!-- IE -->'));
			}

			// Render control HTML

			
			h += '<div class="mceToolbarItem">' + co.renderHTML() + '</div>';

			// Add toolbar start after list box and before the next button
			// This is to fix the o2k7 editor skins
			if (nx && co.ListBox) {
				if (nx.Button || nx.SplitButton)
					h += dom.createHTML('div', {'class' : 'mceToolbarStart'}, dom.createHTML('span', null, '<!-- IE -->'));
			}
		}

		c = 'mceToolbarEnd';

		if (co.Button)
			c += ' mceToolbarEndButton';
		else if (co.SplitButton)
			c += ' mceToolbarEndSplitButton';
		else if (co.ListBox)
			c += ' mceToolbarEndListBox';

		h += dom.createHTML('div', {'class' : c}, dom.createHTML('span', null, '<!-- IE -->'));

		return dom.createHTML('div', {id : t.id, 'class' : 'mceToolbar' + (s['class'] ? ' ' + s['class'] : ''), align : t.settings.align || ''},  h );
	}

	/**#@-*/
});
