/**
 * $Id: editor_plugin_src.js 999 2009-02-10 17:42:58Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function() {
	var DOM = tinymce.DOM, Element = tinymce.dom.Element, Event = tinymce.dom.Event, each = tinymce.each, is = tinymce.is;

	tinymce.create('Skyline.Editor.plugins.SkylineWindows', {
		init : function(ed, url) {
			// Replace window manager
			ed.onBeforeRenderUI.add(function() {
				ed.windowManager = new Skyline.Editor.WindowManager(ed);
			});
		},

		getInfo : function() {
			return {
				longname : 'InlinePopups',
				author : 'Moxiecode Systems AB',
				authorurl : 'http://tinymce.moxiecode.com',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/inlinepopups',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	tinymce.create('Skyline.Editor.WindowManager:tinymce.WindowManager', {
		WindowManager : function(ed) {
			var t = this;

			t.parent(ed);
			t.zIndex = 300000;
			t.count = 0;
			t.windows = {};
		},

		open : function(f, p) {
			var t = this, id, opt = '', ed = t.editor, dw = 0, dh = 0, vp, po, mdf, clf, we, w, u;

			f = f || {};
			p = p || {};

			// Run native windows
			if (!f.inline)
				return t.parent(f, p);

			// Only store selection if the type is a normal window
			if (!f.type)
				t.bookmark = ed.selection.getBookmark('simple');

			id = DOM.uniqueId();
			vp = DOM.getViewPort();
			f.width = parseInt(f.width || 320);
			f.height = parseInt(f.height || 240) + (tinymce.isIE ? 8 : 0);
			f.min_width = parseInt(f.min_width || 150);
			f.min_height = parseInt(f.min_height || 100);
			f.max_width = parseInt(f.max_width || 2000);
			f.max_height = parseInt(f.max_height || 2000);
			f.left = f.left || Math.round(Math.max(vp.x, vp.x + (vp.w / 2.0) - (f.width / 2.0)));
			f.top = f.top || Math.round(Math.max(vp.y, vp.y + (vp.h / 2.0) - (f.height / 2.0)));
			f.movable = f.resizable = true;
			p.mce_width = f.width;
			p.mce_height = f.height;
			p.mce_inline = true;
			p.mce_window_id = id;
			p.mce_auto_focus = f.auto_focus;
			
			var dialog = new Skyline.Dialog(f);

			t.features = f;
			t.params = p;
			t.onOpen.dispatch(t, f, p);

			if (f.type) {
				opt += ' mceModal';

				if (f.type)
					opt += ' mce' + f.type.substring(0, 1).toUpperCase() + f.type.substring(1);

				f.resizable = false;
			}

			if (f.statusbar)
				opt += ' mceStatusbar';

			if (f.resizable)
				opt += ' mceResizable';

			if (f.minimizable)
				opt += ' mceMinimizable';

			if (f.maximizable)
				opt += ' mceMaximizable';

			if (f.movable)
				opt += ' mceMovable';

			u = f.url || f.file;
			if (u) {
				if (tinymce.relaxedDomain)
					u += (u.indexOf('?') == -1 ? '?' : '&') + 'mce_rdomain=' + tinymce.relaxedDomain;

				u = tinymce._addVer(u);
			}

			if (!f.type) {
        DOM.add(dialog.contentEl, 'iframe', {id : id + '_ifr', src : 'javascript:""', frameBorder : 0, style : 'border:0;width:10px;height:10px'});
        DOM.setStyles(id + '_ifr', {width : f.width, height : f.height});
        DOM.setAttrib(id + '_ifr', 'src', u);
			} else {
        // DOM.add(id + '_wrapper', 'a', {id : id + '_ok', 'class' : 'mceButton mceOk', href : 'javascript:;', onmousedown : 'return false;'}, 'Ok');
        // 
        // if (f.type == 'confirm')
        //  DOM.add(id + '_wrapper', 'a', {'class' : 'mceButton mceCancel', href : 'javascript:;', onmousedown : 'return false;'}, 'Cancel');
        // 
        // DOM.add(id + '_middle', 'div', {'class' : 'mceIcon'});
				dialog.updateContent(f.content.replace('\n', '<br />'));
			}

			// Add window
			w = t.windows[id] = {
				id : id,
				dialog : dialog,
				features : f,
				iframeElement : new Element(id + '_ifr')
			};

      dialog.addEvent("close",t._onDialogClose.bind(t,w));

			// Setup blocker
			dialog.setup();
			dialog.show();

			// Focus ok button
			if (DOM.get(id + '_ok'))
				DOM.get(id + '_ok').focus();

			t.count++;

			return w;
		},

		focus : function(id) {
			var t = this, w;

			if (w = t.windows[id]) {
			  w.dialog.focus();
			}
		},

		resizeBy : function(dw, dh, id) {
      // TODO
      var w = this.windows[id];
       
      if (w) {
        w.iframeElement.resizeBy(dw, dh);
      }
		},

		close : function(win, id) {
			var t = this, w, d = DOM.doc, ix = 0, fw, id;

			id = t._findId(id || win);

			// Probably not inline
			if (!t.windows[id]) {
				t.parent(win);
				return;
			}

			t.count--;

			if (w = t.windows[id]) {
				w.dialog.close();
			}
		},
				
		setTitle : function(w, ti) {
		  var w = this._findWindow(w);
		  w.dialog.setTitle(DOM.encode(ti));
		},

		alert : function(txt, cb, s) {
			var t = this, w;

			w = t.open({
				title : t,
				type : 'alert',
				button_func : function(s) {
					if (cb)
						cb.call(s || t, s);

					t.close(null, w.id);
				},
				content : DOM.encode(t.editor.getLang(txt, txt)),
				inline : 1,
				width : 400,
				height : 130
			});
		},

		confirm : function(txt, cb, s) {
			var t = this, w;

			w = t.open({
				title : t,
				type : 'confirm',
				button_func : function(s) {
					if (cb)
						cb.call(s || t, s);

					t.close(null, w.id);
				},
				content : DOM.encode(t.editor.getLang(txt, txt)),
				inline : 1,
				width : 400,
				height : 130
			});
		},

		// Internal functions
		
	  // Dialog Close event
		_onDialogClose : function(w){
		  var id = w.id;		
		  this.onClose.dispatch(this);
			Event.clear(id);
			Event.clear(id + '_ifr');

			DOM.setAttrib(id + '_ifr', 'src', 'javascript:""'); // Prevent leak		  
			delete this.windows[id];
		},	

		_findId : function(w) {
			var t = this;

			if (typeof(w) == 'string')
				return w;

			each(t.windows, function(wo) {
				var ifr = DOM.get(wo.id + '_ifr');

				if (ifr && w == ifr.contentWindow) {
					w = wo.id;
					return false;
				}
			});

			return w;
		},
		_findWindow : function(w){
			var t = this;
			return t.windows[t._findId(w)];		  
		}
	});

	// Register plugin
	tinymce.PluginManager.add('skylinewindows', Skyline.Editor.plugins.SkylineWindows);
})();

