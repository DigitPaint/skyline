/**
 * $Id: editor_plugin_src.js 539 2008-01-14 19:08:58Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function() {
	tinymce.create('Skyline.Editor.plugins.SkylineLink', {
		init : function(ed, url) {
			this.editor = ed;

			// Register commands
			ed.addCommand('mceSklLink', function() {
				var se = ed.selection;

				// No selection and not in link
				if (se.isCollapsed() && !ed.dom.getParent(se.getNode(), 'A'))
					return;

        new Skyline.Editor.plugins.SkylineLink.Dialog(ed);
			});

			// Register buttons
			ed.addButton('link', {
				title : 'skyline.link_desc',
				cmd : 'mceSklLink'
			});

			ed.addShortcut('ctrl+k', 'skyline.link_desc', 'mceSklLink');

			ed.onNodeChange.add(function(ed, cm, n, co) {
				cm.setDisabled('link', co && n.nodeName != 'A');
				cm.setActive('link', n.nodeName == 'A' && !n.name);
			});
		},

		getInfo : function() {
			return {
				longname : 'Skyline Link',
				author : 'DigitPaint BV',
				authorurl : 'http://www.digitpaint.nl',
				infourl : 'http://www.digitpaint.nl',
				version : "1.0"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('skylinelink', Skyline.Editor.plugins.SkylineLink);
})();