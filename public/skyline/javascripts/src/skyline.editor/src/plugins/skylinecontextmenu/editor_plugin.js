/**
 * $Id: editor_plugin_src.js 848 2008-05-15 11:54:40Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function() {
	var Event = tinymce.dom.Event, each = tinymce.each, DOM = tinymce.DOM;

	tinymce.create('Skyline.Editor.plugins.SkylineContextMenu', {
		init : function(ed) {
			var t = this;

			t.editor = ed;
			this._menus = [];

			ed.onContextMenu.add(function(ed, e) {
			  if(e.ctrlKey){ return; }
  			var sm, se = ed.selection, col = se.isCollapsed(), el = se.getNode() || ed.getBody();			
  			
  			var m = t._getMenu(ed);
  			var hasItems = 0;
  			
  			each(t._menus,function(mfun){
  			  if(mfun(m,el,se,col,ed)){
  			    hasItems += 1;  			    
  			  };
  			});
  			
				if (hasItems > 0) {
				  t._menu = m;
					m.showMenu(e.clientX, e.clientY);
					Event.add(ed.getDoc(), 'click', hide);
					Event.cancel(e);
				}
			});

			function hide() {
				if (t._menu) {
					t._menu.removeAll();
					t._menu.destroy();
					Event.remove(ed.getDoc(), 'click', hide);
				}
			};

			ed.onMouseDown.add(hide);
			ed.onKeyDown.add(hide);		
		},

		getInfo : function() {
			return {
				longname : 'Skyline Contextmenu',
				author : 'DigitPaint BV',
				authorurl : 'http://tinymce.moxiecode.com',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/contextmenu',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		},
		
		registerMenu : function(fun){
		  this._menus.push(fun);
		},

		_getMenu : function(ed) {
			var t = this, m = t._menu, am, p1, p2;

			if (m) {
				m.removeAll();
				m.destroy();
			}

			p1 = DOM.getPos(ed.getContentAreaContainer());
			p2 = DOM.getPos(ed.getContainer());

			m = ed.controlManager.createDropMenu('contextmenu', {
			  "class" : "tinymce",
				offset_x : p1.x + ed.getParam('contextmenu_offset_x', 0),
				offset_y : p1.y + ed.getParam('contextmenu_offset_y', 0),
				constrain : 1
			});

			return m;
		}
	});

	// Register plugin
	tinymce.PluginManager.add('skylinecontextmenu', Skyline.Editor.plugins.SkylineContextMenu);
})();