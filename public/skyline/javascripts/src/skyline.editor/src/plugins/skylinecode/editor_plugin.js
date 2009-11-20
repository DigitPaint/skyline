/**
 * $Id: editor_plugin_src.js 539 2008-01-14 19:08:58Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function() {
	tinymce.create('Skyline.Editor.plugins.SkylineCode', {
		init : function(ed, url) {
			this.editor = ed;

			// Register commands
			ed.addCommand('mceSklCode', function() {
        new Skyline.Editor.plugins.SkylineCode.Dialog(ed);
			});

			// Register buttons
			ed.addButton('code', {
				title : 'skyline.code_desc',
				cmd : 'mceSklCode'
			});
		},

		getInfo : function() {
			return {
				longname : 'Skyline Code Editor',
				author : 'DigitPaint BV',
				authorurl : 'http://www.digitpaint.nl',
				infourl : 'http://www.digitpaint.nl',
				version : "1.0"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('skylinecode', Skyline.Editor.plugins.SkylineCode);
})();