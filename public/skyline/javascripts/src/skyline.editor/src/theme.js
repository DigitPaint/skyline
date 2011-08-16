/**
 * $Id: editor_template_src.js 1045 2009-03-04 20:03:18Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function(tinymce) {
	var DOM = tinymce.DOM, Event = tinymce.dom.Event, extend = tinymce.extend, each = tinymce.each, Cookie = tinymce.util.Cookie, lastExtID, explode = tinymce.explode;

	// Tell it to load theme specific language pack(s)
  tinymce.ThemeManager.requireLangPack('skyline');

	tinymce.create('Skyline.Editor.TinyMceTheme', {
		sizes : [8, 10, 12, 14, 18, 24, 36],

		// Control name lookup, format: title, command
		controls : {
			bold : ['bold_desc', 'Bold'],
			italic : ['italic_desc', 'Italic'],
			underline : ['underline_desc', 'Underline'],
			strikethrough : ['striketrough_desc', 'Strikethrough'],
			justifyleft : ['justifyleft_desc', 'JustifyLeft'],
			justifycenter : ['justifycenter_desc', 'JustifyCenter'],
			justifyright : ['justifyright_desc', 'JustifyRight'],
			justifyfull : ['justifyfull_desc', 'JustifyFull'],
			bullist : ['bullist_desc', 'InsertUnorderedList'],
			numlist : ['numlist_desc', 'InsertOrderedList'],
			outdent : ['outdent_desc', 'Outdent'],
			indent : ['indent_desc', 'Indent'],
			cut : ['cut_desc', 'Cut'],
			copy : ['copy_desc', 'Copy'],
			paste : ['paste_desc', 'Paste'],
			undo : ['undo_desc', 'Undo'],
			redo : ['redo_desc', 'Redo'],
			link : ['link_desc', 'mceLink'],
			unlink : ['unlink_desc', 'unlink'],
			image : ['image_desc', 'mceImage'],
			cleanup : ['cleanup_desc', 'mceCleanup'],
			code : ['code_desc', 'mceCodeEditor'],
			hr : ['hr_desc', 'InsertHorizontalRule'],
			removeformat : ['removeformat_desc', 'RemoveFormat'],
			sub : ['sub_desc', 'subscript'],
			sup : ['sup_desc', 'superscript'],
			forecolor : ['forecolor_desc', 'ForeColor'],
			forecolorpicker : ['forecolor_desc', 'mceForeColor'],
			backcolor : ['backcolor_desc', 'HiliteColor'],
			backcolorpicker : ['backcolor_desc', 'mceBackColor'],
			charmap : ['charmap_desc', 'mceCharMap'],
			visualaid : ['visualaid_desc', 'mceToggleVisualAid'],
			anchor : ['anchor_desc', 'mceInsertAnchor'],
			newdocument : ['newdocument_desc', 'mceNewDocument'],
			blockquote : ['blockquote_desc', 'mceBlockQuote']
		},

		stateControls : ['bold', 'italic', 'underline', 'strikethrough', 'bullist', 'numlist', 'justifyleft', 'justifycenter', 'justifyright', 'justifyfull', 'sub', 'sup', 'blockquote'],

		getInfo : function() {
			return {
				longname : 'Skyline theme',
				author : 'DigitPaint BV',
				authorurl : 'http://tinymce.moxiecode.com',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		},

		init : function(ed, url) {
			var t = this, s, v, o;
	
			t.editor = ed;
			t.url = url;
			t.onResolveName = new tinymce.util.Dispatcher(this);
			t.toolbars = [];

			// Default settings
			t.settings = s = extend({
				theme_advanced_path : true,
				theme_advanced_toolbar_location : 'bottom',
        theme_advanced_toolbars : [
          "bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull",
          "bullist,numlist,|,outdent,indent,|,undo,redo,|,link,unlink,image",
          "sub,sup"
        ],
				theme_advanced_blockformats : "p,address,pre,h1,h2,h3,h4,h5,h6",
				theme_advanced_toolbar_align : "center",
				theme_advanced_more_colors : 1,
				theme_advanced_row_height : 23,
				theme_advanced_resize_horizontal : 1,
				theme_advanced_resizing_use_cookie : 1,
				readonly : ed.settings.readonly
			}, ed.settings);

      if(!ed.onFocus){
        ed.onFocus = new tinymce.util.Dispatcher(ed);
      }

			// Init editor
			ed.onInit.add(function() {
				ed.onNodeChange.add(t._nodeChanged, t);

				if (ed.settings.content_css === false){
					ed.dom.loadCSS(ed.baseURI.toAbsolute("assets/content.css"));
				}
				
        var ifr = DOM.get(ed.id + '_ifr');
        if(ifr.contentWindow){
          ifr = ifr.contentWindow;
        }
        
        Event.add(ifr,"focus",function(){
          ed.onFocus.dispatch(ed);
          t._onFocus();
        });
        
			});
			
      // Add custom classes
      ed.onBeforeRenderUI.add(function(){
        ed.controlManager.setControlType("separator", Skyline.Editor.Separator);
        ed.controlManager.setControlType("toolbar", Skyline.Editor.Toolbar);        
      });
			
			
			
      ed.onActivate.add(t._onActivate,t);
      ed.onDeactivate.add(t._onDeactivate,t);
      
			ed.onSetProgressState.add(function(ed, b, ti) {
				var co, id = ed.id, tb;

				if (b) {
					t.progressTimer = setTimeout(function() {
						co = ed.getContainer();
						co = co.insertBefore(DOM.create('DIV', {style : 'position:relative'}), co.firstChild);
						tb = DOM.get(ed.id + '_tbl');

						DOM.add(co, 'div', {id : id + '_blocker', 'class' : 'mceBlocker', style : {width : tb.clientWidth + 2, height : tb.clientHeight + 2}});
						DOM.add(co, 'div', {id : id + '_progress', 'class' : 'mceProgress', style : {left : tb.clientWidth / 2, top : tb.clientHeight / 2}});
					}, ti || 0);
				} else {
					DOM.remove(id + '_blocker');
					DOM.remove(id + '_progress');
					clearTimeout(t.progressTimer);
				}
			});

		},

		createControl : function(n, cf) {
			var cd, c;

			if (c = cf.createControl(n)){
				return c;
			}

			switch (n) {
				case "styleselect":
					return this._createStyleSelect();

				case "formatselect":
					return this._createBlockFormats();

				case "forecolor":
					return this._createForeColorMenu();

				case "backcolor":
					return this._createBackColorMenu();
			}

			if ((cd = this.controls[n])){
				return cf.createButton(n, {title : "skyline." + cd[0], cmd : cd[1], ui : cd[2], value : cd[3]});
			}
		},

		execCommand : function(cmd, ui, val) {
			var f = this['_' + cmd];

			if (f) {
				f.call(this, ui, val);
				return true;
			}

			return false;
		},

		renderUI : function(o) {
			var n, ic, tb, t = this, ed = t.editor, s = t.settings, sc, p, nl;

			n = p = DOM.create('span', {id : ed.id + '_parent', 'class' : 'mceEditor'});

			if (!DOM.boxModel)
				n = DOM.add(n, 'div', {'class' : 'mceOldBoxModel'});

			n = sc = DOM.add(n, 'table', {id : ed.id + '_tbl', 'class' : 'mceLayout', cellSpacing : 0, cellPadding : 0});
			n = tb = DOM.add(n, 'tbody');

      ic = t._skylineLayout(s, tb, o);

			n = o.targetNode;

			// Add classes to first and last TRs
			nl = DOM.stdMode ? sc.getElementsByTagName('tr') : sc.rows; // Quick fix for IE 8
			DOM.addClass(nl[0], 'mceFirst');
			DOM.addClass(nl[nl.length - 1], 'mceLast');

			// Add classes to first and last TDs
			each(DOM.select('tr', tb), function(n) {
				DOM.addClass(n.firstChild, 'mceFirst');
				DOM.addClass(n.childNodes[n.childNodes.length - 1], 'mceLast');
			});

			DOM.insertAfter(p, n);

			if (!ed.getParam('accessibility_focus'))
				Event.add(DOM.add(p, 'a', {href : '#'}, '<!-- IE -->'), 'focus', function() {tinyMCE.get(ed.id).focus();});

			t.deltaHeight = o.deltaHeight;
			o.targetNode = null;

			return {
				iframeContainer : ic,
				editorContainer : ed.id + '_parent',
				sizeContainer : sc,
				deltaHeight : o.deltaHeight
			};
		},

		resizeBy : function(dw, dh) {
			var e = DOM.get(this.editor.id + '_tbl');
			this.resizeTo(e.clientWidth + dw, e.clientHeight + dh);
		},

		resizeTo : function(w, h) {
			var ed = this.editor, s = ed.settings, e = DOM.get(ed.id + '_tbl'), ifr = DOM.get(ed.id + '_ifr'), dh;

			// Boundery fix box
      w = Math.max(s.theme_advanced_resizing_min_width || 100, w);
      h = Math.max(s.theme_advanced_resizing_min_height || 100, h);
      w = Math.min(s.theme_advanced_resizing_max_width || 0xFFFF, w);
      h = Math.min(s.theme_advanced_resizing_max_height || 0xFFFF, h);

			// Calc difference between iframe and container
      dh = e.clientHeight - ifr.clientHeight;

			// Resize iframe and container
			DOM.setStyle(ifr, 'height', h - dh);
			DOM.setStyles(e, {width : w, height : h});
		},
		
		destroy : function() {
			var id = this.editor.id;

			Event.clear(id + '_resize');
			Event.clear(id + '_external_close');
		},

		// Internal functions
			
	  _onFocus : function(){
      this._onActivate();
	  },
		_onActivate : function(){
			var t = this, ed = t.editor;
		  each(t.toolbars,function(to){
		    to.setState("hidden",false);
		  });
		},
		
		_onDeactivate : function(){
			var t = this, ed = t.editor;			
		  each(t.toolbars,function(to){
		    to.setState("hidden",true);
		  });
		  
		},

    _skylineLayout : function(s,tb,o){
      var t = this, ed = t.editor, dc, da, cf = ed.controlManager, n, ic, to, a;

			n = DOM.add(tb, 'tr');
			n = ic = DOM.add(n, 'td', {'class' : 'mceIframeContainer'});

      // Move the rendering out of the screen
      var cont = DOM.create("div",{style: "width: 5000px; position:absolute; left: -100000000000px"});
      var container = DOM.add(ed.settings.skyline_toolbar_container,cont);
      var i = 1;
      each(s['theme_advanced_toolbars'],function(v){
				a = 'mceLeft';

				n = DOM.add(cont, 'div', {
					'class' : 'mceToolbarContainer ' + a
				});

        to = cf.createToolbar("toolbar"+i,{});
        t._addControls(v, to);
        DOM.setHTML(n, to.renderHTML());
        var tn = DOM.get(to.id);

        // Do some resizing magic so the toolbar get's a decent width.
        DOM.setStyles(n,{"width":"1000px"});
        var rect = DOM.getRect(tn);
        DOM.setStyles(n,{"width":"auto"});          
        DOM.setStyles(tn,{"width":rect.w + "px"});          
        to.setState("hidden",true);
        t.toolbars.push(to);        
        i += 1;
      })
			
      DOM.setStyles(cont,{width: "auto", position: "static", left: "auto"});
			
      return ic
    },

		_addControls : function(v, tb) {
			var t = this, s = t.settings, di, cf = t.editor.controlManager;

			if (s.theme_advanced_disable && !t._disabled) {
				di = {};

				each(explode(s.theme_advanced_disable), function(v) {
					di[v] = 1;
				});

				t._disabled = di;
			} else
				di = t._disabled;

			each(explode(v), function(n) {
				var c;

				if (di && di[n])
					return;

				c = t.createControl(n, cf);

				if (c)
					tb.add(c);
			});
		},
		
		_nodeChanged : function(ed, cm, n, co) {
			var t = this, p, de = 0, v, c, s = t.settings, cl, fz, fn;

			if (s.readonly)
				return;

			tinymce.each(t.stateControls, function(c) {
				cm.setActive(c, ed.queryCommandState(t.controls[c][1]));
			});

			cm.setActive('visualaid', ed.hasVisual);
			cm.setDisabled('undo', !ed.undoManager.hasUndo() && !ed.typing);
			cm.setDisabled('redo', !ed.undoManager.hasRedo());
			cm.setDisabled('outdent', !ed.queryCommandState('Outdent'));

			p = DOM.getParent(n, 'A');
			if (c = cm.get('link')) {
				if (!p || !p.name) {
					c.setDisabled(!p && co);
					c.setActive(!!p);
				}
			}

			if (c = cm.get('unlink')) {
				c.setDisabled(!p && co);
				c.setActive(!!p && !p.name);
			}

			if (c = cm.get('anchor')) {
				c.setActive(!!p && p.name);

				if (tinymce.isWebKit) {
					p = DOM.getParent(n, 'IMG');
					c.setActive(!!p && DOM.getAttrib(p, 'mce_name') == 'a');
				}
			}

			p = DOM.getParent(n, 'IMG');
			if (c = cm.get('image'))
				c.setActive(!!p && n.className.indexOf('mceItem') == -1);

			if (c = cm.get('styleselect')) {
				if (n.className) {
					t._importClasses();
					c.select(n.className);
				} else
					c.select();
			}

			if (c = cm.get('formatselect')) {
				p = DOM.getParent(n, DOM.isBlock);

				if (p)
					c.select(p.nodeName.toLowerCase());
			}

			if (ed.settings.convert_fonts_to_spans) {
				ed.dom.getParent(n, function(n) {
					if (n.nodeName === 'SPAN') {
						if (!cl && n.className)
							cl = n.className;

						if (!fz && n.style.fontSize)
							fz = n.style.fontSize;

						if (!fn && n.style.fontFamily)
							fn = n.style.fontFamily.replace(/[\"\']+/g, '').replace(/^([^,]+).*/, '$1').toLowerCase();
					}

					return false;
				});

			}

		},

		// Commands gets called by execCommand

		_sel : function(v) {
			this.editor.execCommand('mceSelectNodeDepth', false, v);
		},

		_mceInsertAnchor : function(ui, v) {
			var ed = this.editor;

			ed.windowManager.open({
				url : tinymce.baseURL + '/dialogs/anchor.htm',
				width : 320 + parseInt(ed.getLang('skyline.anchor_delta_width', 0)),
				height : 90 + parseInt(ed.getLang('skyline.anchor_delta_height', 0)),
				inline : true
			}, {
				theme_url : this.url
			});
		},

		_mceCharMap : function() {
			var ed = this.editor;

			ed.windowManager.open({
				url : tinymce.baseURL + '/dialogs/charmap.htm',
				width : 550 + parseInt(ed.getLang('skyline.charmap_delta_width', 0)),
				height : 250 + parseInt(ed.getLang('skyline.charmap_delta_height', 0)),
				inline : true
			}, {
				theme_url : this.url
			});
		},
		_mceColorPicker : function(u, v) {
			var ed = this.editor;

			v = v || {};

			ed.windowManager.open({
				url : tinymce.baseURL + '/dialogs/color_picker.htm',
				width : 375 + parseInt(ed.getLang('skyline.colorpicker_delta_width', 0)),
				height : 250 + parseInt(ed.getLang('skyline.colorpicker_delta_height', 0)),
				close_previous : false,
				inline : true
			}, {
				input_color : v.color,
				func : v.func,
				theme_url : this.url
			});
		},

		_mceCodeEditor : function(ui, val) {
			var ed = this.editor;

			ed.windowManager.open({
				url : tinymce.baseURL + '/dialogs/source_editor.htm',
				width : parseInt(ed.getParam("theme_advanced_source_editor_width", 720)),
				height : parseInt(ed.getParam("theme_advanced_source_editor_height", 580)),
				inline : true,
				resizable : true,
				maximizable : true
			}, {
				theme_url : this.url
			});
		},

		_mceForeColor : function() {
			var t = this;

			this._mceColorPicker(0, {
				color: t.fgColor,
				func : function(co) {
					t.fgColor = co;
					t.editor.execCommand('ForeColor', false, co);
				}
			});
		},

		_mceBackColor : function() {
			var t = this;

			this._mceColorPicker(0, {
				color: t.bgColor,
				func : function(co) {
					t.bgColor = co;
					t.editor.execCommand('HiliteColor', false, co);
				}
			});
		},

		_ufirst : function(s) {
			return s.substring(0, 1).toUpperCase() + s.substring(1);
		},
		
    // Extra control structures
		_importClasses : function(e) {
			var ed = this.editor, c = ed.controlManager.get('styleselect');

			if (c.getLength() == 0) {
				each(ed.dom.getClasses(), function(o) {
					c.add(o['class'], o['class']);
				});
			}
		},

		_createStyleSelect : function(n) {
			var t = this, ed = t.editor, cf = ed.controlManager, c = cf.createListBox('styleselect', {
				title : 'skyline.style_select',
				onselect : function(v) {
					if (c.selectedValue === v) {
						ed.execCommand('mceSetStyleInfo', 0, {command : 'removeformat'});
						c.select();
						return false;
					} else
						ed.execCommand('mceSetCSSClass', 0, v);
				}
			});

			if (c) {
				each(ed.getParam('theme_advanced_styles', '', 'hash'), function(v, k) {
					if (v)
						c.add(t.editor.translate(k), v);
				});

				c.onPostRender.add(function(ed, n) {
					if (!c.NativeListBox) {
						Event.add(n.id + '_text', 'focus', t._importClasses, t);
						Event.add(n.id + '_text', 'mousedown', t._importClasses, t);
						Event.add(n.id + '_open', 'focus', t._importClasses, t);
						Event.add(n.id + '_open', 'mousedown', t._importClasses, t);
					} else
						Event.add(n.id, 'focus', t._importClasses, t);
				});
			}

			return c;
		},


		_createBlockFormats : function() {
			var c, fmts = {
				p : 'skyline.paragraph',
				address : 'skyline.address',
				pre : 'skyline.pre',
				h1 : 'skyline.h1',
				h2 : 'skyline.h2',
				h3 : 'skyline.h3',
				h4 : 'skyline.h4',
				h5 : 'skyline.h5',
				h6 : 'skyline.h6',
				div : 'skyline.div',
				blockquote : 'skyline.blockquote',
				code : 'skyline.code',
				dt : 'skyline.dt',
				dd : 'skyline.dd',
				samp : 'skyline.samp'
			}, t = this;

			c = t.editor.controlManager.createListBox('formatselect', {title : 'skyline.block', cmd : 'FormatBlock'});
			if (c) {
				each(t.editor.getParam('theme_advanced_blockformats', t.settings.theme_advanced_blockformats, 'hash'), function(v, k) {
					c.add(t.editor.translate(k != v ? k : fmts[v]), v, {'class' : 'mce_formatPreview mce_' + v});
				});
			}

			return c;
		},

		_createForeColorMenu : function() {
			var c, t = this, s = t.settings, o = {}, v;

			if (s.theme_advanced_more_colors) {
				o.more_colors_func = function() {
					t._mceColorPicker(0, {
						color : c.value,
						func : function(co) {
							c.setColor(co);
						}
					});
				};
			}

			if (v = s.theme_advanced_text_colors)
				o.colors = v;

			if (s.theme_advanced_default_foreground_color)
				o.default_color = s.theme_advanced_default_foreground_color;

			o.title = 'skyline.forecolor_desc';
			o.cmd = 'ForeColor';
			o.scope = this;

			c = t.editor.controlManager.createColorSplitButton('forecolor', o);

			return c;
		},

		_createBackColorMenu : function() {
			var c, t = this, s = t.settings, o = {}, v;

			if (s.theme_advanced_more_colors) {
				o.more_colors_func = function() {
					t._mceColorPicker(0, {
						color : c.value,
						func : function(co) {
							c.setColor(co);
						}
					});
				};
			}

			if (v = s.theme_advanced_background_colors)
				o.colors = v;

			if (s.theme_advanced_default_background_color)
				o.default_color = s.theme_advanced_default_background_color;

			o.title = 'skyline.backcolor_desc';
			o.cmd = 'HiliteColor';
			o.scope = this;

			c = t.editor.controlManager.createColorSplitButton('backcolor', o);

			return c;
		}    
		
	});

	tinymce.ThemeManager.add('skyline', Skyline.Editor.TinyMceTheme);
}(tinymce));