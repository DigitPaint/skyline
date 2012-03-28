// Namespaces
plupload = {}
plupload.runtimes = {}

// Classes
plupload.runtimes.BrowserPlus = function() {
	/// <summary>Yahoo BrowserPlus implementation.</summary>
}

plupload.runtimes.BrowserPlus.init = function(uploader, callback) {
	/// <summary>Initializes the browserplus runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.runtimes.Flash = function() {
	/// <summary>FlashRuntime implementation.</summary>
}

plupload.runtimes.Flash.init = function(uploader, callback) {
	/// <summary>Initializes the upload runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.runtimes.Gears = function() {
	/// <summary>Gears implementation.</summary>
}

plupload.runtimes.Gears.init = function(uploader, callback) {
	/// <summary>Initializes the upload runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.runtimes.Html4 = function() {
	/// <summary>HTML4 implementation.</summary>
}

plupload.runtimes.Html4.init = function(uploader, callback) {
	/// <summary>Initializes the upload runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.runtimes.Html5 = function() {
	/// <summary>HMTL5 implementation.</summary>
}

plupload.runtimes.Html5.init = function(uploader, callback) {
	/// <summary>Initializes the upload runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.runtimes.Silverlight = function() {
	/// <summary>Silverlight implementation.</summary>
}

plupload.runtimes.Silverlight.init = function(uploader, callback) {
	/// <summary>Initializes the upload runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.Uploader = function(settings) {
	/// <summary>Uploader class, an instance of this class will be created for each upload field.</summary>
	/// <param name="settings" type="Object">Initialization settings, to be used by the uploader instance and runtimes.</param>
	/// <field name="state" type="Number">Current state of the total uploading progress. This one can either be plupload.STARTED or plupload.STOPPED. These states are controlled by the stop/start methods. The default value is STOPPED.</field>
	/// <field name="runtime" type="String">Current runtime name.</field>
	/// <field name="features" type="Object">Map of features that are available for the uploader runtime. Features will be filled before the init event is called, these features can then be used to alter the UI for the end user. Some of the current features that might be in this map is: dragdrop, chunks, jpgresize, pngresize.</field>
	/// <field name="files" type="Array">Current upload queue, an array of File instances.</field>
	/// <field name="settings" type="Object">Object with name/value settings.</field>
	/// <field name="total" type="plupload.QueueProgress">Total progess information. How many files has been uploaded, total percent etc.</field>
	/// <field name="id" type="String">Unique id for the Uploader instance.</field>
}

plupload.Uploader.prototype.init = function() {
	/// <summary>Initializes the Uploader instance and adds internal event listeners.</summary>
}

plupload.Uploader.prototype.refresh = function() {
	/// <summary>Refreshes the upload instance by dispatching out a refresh event to all runtimes.</summary>
}

plupload.Uploader.prototype.start = function() {
	/// <summary>Starts uploading the queued files.</summary>
}

plupload.Uploader.prototype.stop = function() {
	/// <summary>Stops the upload of the queued files.</summary>
}

plupload.Uploader.prototype.getFile = function(id) {
	/// <summary>Returns the specified file object by id.</summary>
	/// <param name="id" type="String">File id to look for.</param>
	/// <returns type="plupload.File">File object or undefined if it wasn't found;</returns>
}

plupload.Uploader.prototype.removeFile = function(file) {
	/// <summary>Removes a specific file.</summary>
	/// <param name="file" type="plupload.File">File to remove from queue.</param>
}

plupload.Uploader.prototype.splice = function(start, length) {
	/// <summary>Removes part of the queue and returns the files removed.</summary>
	/// <param name="start" type="Number" integer="true">(Optional) Start index to remove from.</param>
	/// <param name="length" type="Number" integer="true">(Optional) Lengh of items to remove.</param>
	/// <returns type="Array">Array of files that was removed.</returns>
}

plupload.Uploader.prototype.trigger = function(name, Multiple) {
	/// <summary>Dispatches the specified event name and it's arguments to all listeners.</summary>
	/// <param name="name" type="String">Event name to fire.</param>
	/// <param name="Multiple" type="Object..">arguments to pass along to the listener functions.</param>
}

plupload.Uploader.prototype.bind = function(name, func, scope) {
	/// <summary>Adds an event listener by name.</summary>
	/// <param name="name" type="String">Event name to listen for.</param>
	/// <param name="func" type="function">Function to call ones the event gets fired.</param>
	/// <param name="scope" type="Object">Optional scope to execute the specified function in.</param>
}

plupload.Uploader.prototype.unbind = function(name, func) {
	/// <summary>Removes the specified event listener.</summary>
	/// <param name="name" type="String">Name of event to remove.</param>
	/// <param name="func" type="function">Function to remove from listener.</param>
}

plupload.Uploader.prototype.unbindAll = function() {
	/// <summary>Removes all event listeners.</summary>
}

plupload.Uploader.prototype.destroy = function() {
	/// <summary>Destroys Plupload instance and cleans after itself.</summary>
}

plupload.File = function(id, name, size) {
	/// <summary>File instance.</summary>
	/// <param name="id" type="String">Unique file id.</param>
	/// <param name="name" type="String">File name.</param>
	/// <param name="size" type="Number" integer="true">File size in bytes.</param>
	/// <field name="id" type="String">File id this is a globally unique id for the specific file.</field>
	/// <field name="name" type="String">File name for example "myfile.gif".</field>
	/// <field name="size" type="Number">File size in bytes.</field>
	/// <field name="loaded" type="Number">Number of bytes uploaded of the files total size.</field>
	/// <field name="percent" type="Number">Number of percentage uploaded of the file.</field>
	/// <field name="status" type="Number">Status constant matching the plupload states QUEUED, UPLOADING, FAILED, DONE.</field>
}

plupload.Runtime = function() {
	/// <summary>Runtime class gets implemented by each upload runtime.</summary>
}

plupload.Runtime.init = function(uploader, callback) {
	/// <summary>Initializes the upload runtime.</summary>
	/// <param name="uploader" type="plupload.Uploader">Uploader instance that needs to be initialized.</param>
	/// <param name="callback" type="function">Callback function to execute when the runtime initializes or fails to initialize. If it succeeds an object with a parameter name success will be set to true.</param>
}

plupload.QueueProgress = function() {
	/// <summary>Runtime class gets implemented by each upload runtime.</summary>
	/// <field name="size" type="Number">Total queue file size.</field>
	/// <field name="loaded" type="Number">Total bytes uploaded.</field>
	/// <field name="uploaded" type="Number">Number of files uploaded.</field>
	/// <field name="failed" type="Number">Number of files failed to upload.</field>
	/// <field name="queued" type="Number">Number of files yet to be uploaded.</field>
	/// <field name="percent" type="Number">Total percent of the uploaded bytes.</field>
	/// <field name="bytesPerSec" type="Number">Bytes uploaded per second.</field>
}

plupload.QueueProgress.prototype.reset = function() {
	/// <summary>Resets the progress to it's initial values.</summary>
}

// Namespaces
plupload.STOPPED = new Object();
plupload.STARTED = new Object();
plupload.QUEUED = new Object();
plupload.UPLOADING = new Object();
plupload.FAILED = new Object();
plupload.DONE = new Object();
plupload.GENERIC_ERROR = new Object();
plupload.HTTP_ERROR = new Object();
plupload.IO_ERROR = new Object();
plupload.SECURITY_ERROR = new Object();
plupload.INIT_ERROR = new Object();
plupload.FILE_SIZE_ERROR = new Object();
plupload.FILE_EXTENSION_ERROR = new Object();
plupload.mimeTypes = new Object();
plupload.extend = function(target, obj) {
	/// <summary>Extends the specified object with another object.</summary>
	/// <param name="target" type="Object">Object to extend.</param>
	/// <param name="obj" type="Object..">Multiple objects to extend with.</param>
	/// <returns type="Object">Same as target, the extended object.</returns>
}

plupload.cleanName = function(s) {
	/// <summary>Cleans the specified name from national characters (diacritics).</summary>
	/// <param name="s" type="String">String to clean up.</param>
	/// <returns type="String">Cleaned string.</returns>
}

plupload.addRuntime = function(name, obj) {
	/// <summary>Adds a specific upload runtime like for example flash or gears.</summary>
	/// <param name="name" type="String">Runtime name for example flash.</param>
	/// <param name="obj" type="Object">Object containing init/destroy method.</param>
}

plupload.guid = function() {
	/// <summary>Generates an unique ID.</summary>
	/// <returns type="String">Virtually unique id.</returns>
}

plupload.formatSize = function(size) {
	/// <summary>Formats the specified number as a size string for example 1024 becomes 1 KB.</summary>
	/// <param name="size" type="Number" integer="true">Size to format as string.</param>
	/// <returns type="String">Formatted size string.</returns>
}

plupload.getPos = function(node, root) {
	/// <summary>Returns the absolute x, y position of an Element.</summary>
	/// <param name="node" type="Element" domElement="true">HTML element or element id to get x, y position from.</param>
	/// <param name="root" type="Element" domElement="true">Optional root element to stop calculations at.</param>
	/// <returns type="object">Absolute position of the specified element object with x, y fields.</returns>
}

plupload.parseSize = function(size) {
	/// <summary>Parses the specified size string into a byte value.</summary>
	/// <param name="size" type="">String to parse or number to just pass through.</param>
	/// <returns type="Number" integer="true">Size in bytes.</returns>
}

plupload.xmlEncode = function(s) {
	/// <summary>Encodes the specified string.</summary>
	/// <param name="s" type="String">String to encode.</param>
	/// <returns type="String">Encoded string.</returns>
}

plupload.toArray = function(obj) {
	/// <summary>Forces anything into an array.</summary>
	/// <param name="obj" type="Object">Object with length field.</param>
	/// <returns type="Array">Array object containing all items.</returns>
}

