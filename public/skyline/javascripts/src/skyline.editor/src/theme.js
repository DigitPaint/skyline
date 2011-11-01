(function(tinymce) {
	var DOM = tinymce.DOM, Event = tinymce.dom.Event, extend = tinymce.extend, each = tinymce.each, Cookie = tinymce.util.Cookie, lastExtID, explode = tinymce.explode;

	// Tell it to load theme specific language pack(s)
  tinymce.ThemeManager.requireLangPack('skyline');
  
	tinymce.create('Skyline.Editor.TinyMceTheme:tinymce.themes.AdvancedTheme', {
		init : function(ed, url) {
			var t = this, s, v, o;
	
			t.editor = ed;
			t.url = url;
			t.onResolveName = new tinymce.util.Dispatcher(this);
			t.toolbars = [];		

			ed.forcedHighContrastMode = ed.settings.detect_highcontrast && t._isHighContrast();
			ed.settings.skin = ed.forcedHighContrastMode ? 'highcontrast' : ed.settings.skin;

      // Setting skyline custom layout
      ed.settings.theme_advanced_layout_manager = "customLayout";
      ed.settings.theme_advanced_custom_layout = t._skylineLayout;
      ed.settings.theme_advanced_resizing_min_height = 0;

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
				theme_advanced_fonts : "Andale Mono=andale mono,times;Arial=arial,helvetica,sans-serif;Arial Black=arial black,avant garde;Book Antiqua=book antiqua,palatino;Comic Sans MS=comic sans ms,sans-serif;Courier New=courier new,courier;Georgia=georgia,palatino;Helvetica=helvetica;Impact=impact,chicago;Symbol=symbol;Tahoma=tahoma,arial,helvetica,sans-serif;Terminal=terminal,monaco;Times New Roman=times new roman,times;Trebuchet MS=trebuchet ms,geneva;Verdana=verdana,geneva;Webdings=webdings;Wingdings=wingdings,zapf dingbats",
				theme_advanced_more_colors : 1,
				theme_advanced_row_height : 23,
				theme_advanced_resize_horizontal : 1,
				theme_advanced_resizing_use_cookie : 1,
				theme_advanced_font_sizes : "1,2,3,4,5,6,7",
				theme_advanced_font_selector : "span",
				theme_advanced_show_current_color: 0,
				readonly : ed.settings.readonly
			}, ed.settings);			

			// Setup default font_size_style_values
			if (!s.font_size_style_values)
				s.font_size_style_values = "8pt,10pt,12pt,14pt,18pt,24pt,36pt";

			if (tinymce.is(s.theme_advanced_font_sizes, 'string')) {
				s.font_size_style_values = tinymce.explode(s.font_size_style_values);
				s.font_size_classes = tinymce.explode(s.font_size_classes || '');

				// Parse string value
				o = {};
				ed.settings.theme_advanced_font_sizes = s.theme_advanced_font_sizes;
				each(ed.getParam('theme_advanced_font_sizes', '', 'hash'), function(v, k) {
					var cl;

					if (k == v && v >= 1 && v <= 7) {
						k = v + ' (' + t.sizes[v - 1] + 'pt)';
						cl = s.font_size_classes[v - 1];
						v = s.font_size_style_values[v - 1] || (t.sizes[v - 1] + 'pt');
					}

					if (/^\s*\./.test(v))
						cl = v.replace(/\./g, '');

					o[k] = cl ? {'class' : cl} : {fontSize : v};
				});

				s.theme_advanced_font_sizes = o;
			}

			if ((v = s.theme_advanced_path_location) && v != 'none')
				s.theme_advanced_statusbar_location = s.theme_advanced_path_location;

			if (s.theme_advanced_statusbar_location == 'none')
				s.theme_advanced_statusbar_location = 0;

			if (ed.settings.content_css === false){
				ed.contentCSS.push(ed.baseURI.toAbsolute("assets/content.css"));
			}				

      if(!ed.onFocus){
        ed.onFocus = new tinymce.util.Dispatcher(ed);
      }

			// Init editor
			ed.onInit.add(function() {
				if (!ed.settings.readonly) {
					ed.onNodeChange.add(t._nodeChanged, t);
					ed.onKeyUp.add(t._updateUndoStatus, t);
					ed.onMouseUp.add(t._updateUndoStatus, t);
					ed.dom.bind(ed.dom.getRoot(), 'dragend', function() {
						t._updateUndoStatus(ed);
					});
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
		
    _skylineLayout : function(s,tb,o){
      var ed = this, theme = ed.theme, dc, da, cf = ed.controlManager, n, ic, to, a;

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
        theme._addControls(v, to);
        DOM.setHTML(n, to.renderHTML());
        var tn = DOM.get(to.id);

        // Do some resizing magic so the toolbar get's a decent width.
        DOM.setStyles(n,{"width":"1000px"});
        var rect = DOM.getRect(tn);
        DOM.setStyles(n,{"width":"auto"});          
        DOM.setStyles(tn,{"width":rect.w + "px"});          
        to.setState("hidden",true);
        theme.toolbars.push(to);        
        i += 1;
      })
			
      DOM.setStyles(cont,{width: "auto", position: "static", left: "auto"});
			
      return ic
    },	
    
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
		  
		getInfo : function() {
			return {
				longname : 'Skyline theme',
				author : 'DigitPaint BV',
				authorurl : 'http://tinymce.moxiecode.com',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}	  
  });
  
	tinymce.ThemeManager.add('skyline', Skyline.Editor.TinyMceTheme);
	
}(tinymce));