(function() {
	tinymce.create('Skyline.Editor.plugins.SkylineImage', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mceSklImage', function() {
				// Internal image object like a flash placeholder
				if (ed.dom.getAttrib(ed.selection.getNode(), 'class').indexOf('mceItem') != -1)
					return;

        new Skyline.Editor.plugins.SkylineImage.Dialog(ed);
			});

			// Register buttons
			ed.addButton('image', {
				title : 'skyline.image_desc',
				cmd : 'mceSklImage'
			});
		},

		getInfo : function() {
			return {
				longname : 'Skyline Image',
				author : 'DigitPaint BV',
				authorurl : 'http://www.digitpaint.nl',
				infourl : 'http://www.digitpaint.nl',
				version : "1.0"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('skylineimage', Skyline.Editor.plugins.SkylineImage);
})();