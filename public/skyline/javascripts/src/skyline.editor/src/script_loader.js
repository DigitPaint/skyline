(function(tinymce) {
	var each = tinymce.each, Event = tinymce.dom.Event;

	/**#@+
	 * @class This class handles asynchronous/synchronous loading of JavaScript files it will execute callbacks when
	 * various items gets loaded. This class is useful to 
	 * @member tinymce.dom.ScriptLoader
	 */
	tinymce.create('Skyline.Editor.ScriptLoader:tinymce.dom.ScriptLoader', {

		/**
		 * Adds a specific script to the load queue of the script loader.
		 *
		 * @param {String} u Absolute URL to script to add.
		 * @param {function} cb Optional callback function to execute ones this script gets loaded.
		 * @param {Object} s Optional scope to execute callback in.
		 * @param {bool} pr Optional state to add to top or bottom of load queue. Defaults to bottom.
		 * @return {object} Load queue object contains, state, url and callback.
		 */
		add : function(u, cb, s, pr) {
			var t = this, lo = t.lookup, o;

			if (o = lo[u]) {
				// Is loaded fire callback
				if (cb && o.state == 2)
					cb.call(s || this);

				return o;
			}

			o = {state : 2, url : u, func : cb, scope : s || this};

			if (pr)
				t.queue.unshift(o);
			else
				t.queue.push(o);

			lo[u] = o;


			return o;
		},

		/**
		 * Loads a specific script directly without adding it to the load queue.
		 *
		 * @param {String} u Absolute URL to script to add.
		 * @param {function} cb Optional callback function to execute ones this script gets loaded.
		 * @param {Object} s Optional scope to execute callback in.
		 */
		load : function(u, cb, s) {
			if (o = t.lookup[u]) {
				// Is loaded fire callback
				if (cb && o.state == 2)
					cb.call(s || t);

				return o;
			}		  
		},

		// Static methods
		'static' : {
			_addOnLoad : function(f) {
				var t = this;

				t._funcs = t._funcs || [];
				t._funcs.push(f);

				return t._funcs.length - 1;
			},

			_onLoad : function(e, u, ix) {
				if (!tinymce.isIE || e.readyState == 'complete')
					this._funcs[ix].call(this);
			},

			/**
			 * Loads the specified script without adding it to any load queue.
			 *
			 * @param {string} u URL to dynamically load.
			 * @param {function} cb Callback function to executed on load.
			 */
			loadScript : function(u, cb) {
				if (cb) {
					cb.call(document, u);
					cb = 0;
				}
			}
		}

		/**#@-*/
	});

	// Global script loader
	tinymce.ScriptLoader = new Skyline.Editor.ScriptLoader();
})(tinymce);
