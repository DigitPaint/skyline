//= require "plupload.js"
//= require "plupload.flash.js"
//= require "plupload.html5.js"

/*
  Class: Application.LibraryUploader
  Implements the specific upload widget for Skyline.
  
  Events:
  
  initialized    - Called after backend initialization
  selectCancel   - Called when the cancel button has been clicked.
  queueChanged   - Called when the Queue has changed.
  uiRefresh      - Called when the UI has changed (size, etc.)
  uploadStarted    - Called when the upload starts
  uploadStopped     - Called when the upload is stopped by user input
  uploadCompleted - Called when all files have been uploaded (or have tried).
  uploadFinished - Called when the finish button is clicked.
  
*/
Application.LibraryUploader = new Class({
  Implements: [Events, Options],
  
  options : {},  
  
  initialize : function(formId, options){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    
    // URL where the flash uploader can be found.
    options.flashSwfUrl = Application.urlPrefix + "/javascripts/src/skyline/vendor/plupload/js/plupload.flash.swf";
    
    this.setOptions(options);
    
    this.formEl = $(formId);
    
    // The queued files (presentation side)
    this.files = [];        
    
    // Bytesize of the queue
    this.size = 0;
  
    // Has the uploader component been initialized?
    this.initialized = false;
    
    // We have not yet completed upload of the current queue
    this.completed = false;
    
    // Do we support drag & drop; will be available after init
    this.supportDragdrop = false;
    
    // The uploadBrowser window
    this.uploadBrowser = new Application.UploadBrowser(this, this.formEl.getElement(".upload-files"));
    
    // The uploadProgress window
    this.uploadProgress = new Application.UploadProgress(this, this.formEl.getElement(".upload-progress"));  
      
    this.options.browseButtonId = this.uploadBrowser.browseEl.get("id");
    
    this._initUploader();    
  },
  
  // Reset the uploader to beginstate
  reset : function(){
    if(this.uploader.files.length > 0){
      this.uploader.splice(0, this.uploader.files.length);
      for(var i = 0; i < this.files.length; i++){
        this.files[i].remove();
      }
    }
    this.files = [];
    this.size = 0;
    this.completed = false;
    
    this.uploader.settings.browse_button = this.options.browseButtonId;
    this.uploader.disableBrowse(false);
    
    this.uploaderInit();    
  },
  
  // Syncs rendered queue with uploader; same as reset but does not clear out the queue;
  _syncQueueWithUploader : function(){
    // Remove all rendered files
    for(var i = 0; i < this.files.length; i++){
      this.files[i].remove();
    }
    
    this.files = [];
    this.size = 0;
    this.completed = true;
    
    // Render files in queue that have not been uploaded
    if(this.uploader.files.length > 0){
      var removeFiles = [];
      var files = this.uploader.files;
      for(var i = 0; i < files.length; i++){
        if(files[i].status == plupload.QUEUED){
          this.addFile(files[i]);
        } else {
          removeFiles.push(i);
          this.completed = false;
        }
      }
      
      // We have to clear them out of the uploader files queue directly to prevent
      // an event calling loop.
      for(var i = 0; i < removeFiles.length; i++){
        this.uploader.files.splice(removeFiles[i],1);
      }
    }
    
    if(this.completed){
       // TODO: do we need this?
    } else {
      this.uploaderInit();
    }
    
    
  },
  
  // Cancel the whole thing
  cancelSelect : function(){
    this.reset();    
    this.fireEvent("selectCancel");
  },
  
  // Finish the upload and close the window.
  finishUpload : function(){
    this.reset();    
    this.fireEvent("uploadFinished");
  },
    
  // Format a number in bytesize (B, KB, MB, GB)
  formatSize : function(s){
    return plupload.formatSize(s);
  },
  
  addFile : function(info){
    var f = new Application.UploadFile(this, info);
    f.render();
    info.view = f; // Add's a backreference to the view (Application.UploadFile)
    this.files.push(f)
    return f;
  },
  
  // Remove a file from the display list and the queue
  removeFile : function(uploadFile){
    var f = this.uploader.getFile(uploadFile.fileId);
    var i = this.files.indexOf(uploadFile);
    if(i >= 0){
      this.files.splice(i,1);      
      // Only remove if it has been removed from the list.
      if(f){
        this.uploader.removeFile(f);
      };      
    };
  },
  
  // Start the actual upload
  startUpload : function(){
    // Reassign the button (as the flash should be visible all the time)
    if(this.uploader.runtime == "flash" || this.uploader.runtime == "silverlight"){
      this.uploader.settings.browse_button = this.uploadProgress.progressBarEl.get("id");
      this.uploader.refresh();      
    }
    
    if(this.uploader.files.length > 0){
      this.uploader.disableBrowse();      
      this.uploader.start();
      this.fireEvent("uploadStarted");      
    }
  },
  
  // Stop the upload, restore the browse view. 
  stopUpload : function(){
    this.uploader.stop();
    this.uploadBrowser.show();
    this.uploadProgress.hide();
    this.uploader.settings.browse_button = this.options.browseButtonId;
    this.uploader.refresh();
    
    // uiChanged is fired here because in StateChange stopped it would fire on complete also.
    this.fireEvent("uiChanged");     
    this.fireEvent("uploadStopped");
  },
  
  // Initialize the uploader events
  _initUploader : function(){    
    // The actual uploader object
    this.uploader = new plupload.Uploader({
      runtimes : "html5, flash",
      browse_button : this.options.browseButtonId,
      container: this.options.containerId,
      flash_swf_url : this.options.flashSwfUrl,
      url : this.formEl.getProperty("action"),
      drop_element : "application",
      // This keeps the browser session intact.
      urlstream_upload: true
    });
        
    // Shortcut to progress.
    this.progress = this.uploader.total;
    
    this.uploader.bind("PostInit", function(upl){ 
      this.initialized = true; 
      this.supportDragdrop = upl.features.dragdrop;
      this.fireEvent("initialized"); 
    }.bind(this));
    
    this.uploader.init();    
    
    // We have to override this stupid methods so the event delegation of mootools won't break
    var fl = $(this.uploader.id + '_flash');
    if(fl){
      fl.get = function(){};
      fl.getParent = function(){};      
    }
    
    // We have to add these after init because we want them to be called AFTER the internal callbacks
    this.uploader.bind("Init", this.uploaderInit.bind(this));
    this.uploader.bind("QueueChanged", this.uploaderQueueChanged.bind(this));
    this.uploader.bind("StateChanged", this.uploaderStateChanged.bind(this));
    this.uploader.bind("UploadProgress", this.uploaderUploadProgress.bind(this));    
    this.uploader.bind("ChunkUploaded", this.uploaderChunkUploaded.bind(this));
    this.uploader.bind("uploadComplete", this.uploaderUploadComplete.bind(this));
    
    this.uploader.bind("Error", this.uploaderError.bind(this));    
    this.uploader.bind("FileUploaded", this.uploaderFileUploaded.bind(this));
    
  },
  
  // Uploader eventpassing
  uploaderInit : function(upl){
    this.uploadBrowser.reset();
    this.uploadProgress.reset();
    this.uploadBrowser.show();
    this.uploadProgress.hide();
    this.uploader.refresh();
    this.fireEvent("uiChanged");
  },
  
  uploaderUploadComplete : function(upl){
    this.uploadBrowser.show();
    this.uploadProgress.hide();
    this.uploadBrowser.uploadCompleted();
    this.fireEvent("uiChanged");
    
    var failure = 0;

    // We have to check manually as plupload hasn't updated the calculations yet.
		for (i = 0; i < upl.files.length; i++) {
      if (upl.files[i].status == plupload.FAILED) {
				failure += 1;
			}
		}
    
    if(failure == 0){
      this.uploadBrowser.setMessage(this.options.allUploadedMessage);
    } else {
      this.uploadBrowser.setMessage(this.options.someUploadedMessage);      
    };
    
    this.completed = true;
    this.fireEvent("uploadCompleted");
  },
  
  uploaderStateChanged : function(upl){
    if(upl.state == plupload.STARTED){
      this.uploadBrowser.hide();
      this.uploadProgress.show();
      this.uploadProgress.uploadStarted();
      this.fireEvent("uiChanged");
    } else if(upl.state == plupload.STOPPED){
      
    }    
  },
  
  // The queue has changed
  uploaderQueueChanged : function(upl){
    this._syncQueueWithUploader();
    this.fireEvent("queueChanged");
    this.size = upl.total.size;
    this.uploadBrowser.update();
  },
  
  // Upload progress
  uploaderUploadProgress : function(upl, file){
    this.uploadProgress.update(file);
  },
  
  uploaderChunkUploaded : function(upl, file, response){
    this.uploadProgress.update(file);
  },
  
  // Internal Uploader Errors (NOT server side errors! (unless it's a true application error))
  uploaderError : function(upl, error){
    if(error.file){
      file.view.uploadFailure(error);
    }
  },
  
  // We have to determine here if the upload succeeded on the server!
  uploaderFileUploaded : function(upl, file, info){    
    // Check to see if upload succeeded
    var response = this.parseResponse(info.response);
    if(response[0] == true){
      file.view.uploadSuccess();
    } else {
      file.view.uploadFailure(response[2]);
      file.status = plupload.FAILED;
    }
  },
  
  // Parses the JSON-RPC response and returns the following Array:
  // [STATUS, result(hash), error(hash)]
  // STATUS is true if succeeded, false if an error is set.
  parseResponse : function(response){
    if(response){
       var resp = JSON.decode(response);
       if(resp["error"]){
         return [false, resp["result"], resp["error"]];
       } else {
         return [true, resp["result"], resp["error"]];
       }
    } else {
      return [null, null, null];
    }
  }
  
  
});

Application.UploadBrowser = new Class({
  initialize : function(base, containerEl){
    var fEl = this.containerEl = $(containerEl);
    this.base = base;
    
    this.listEl = fEl.getElement("ul.files");  // The file list
    this.browseEl = fEl.getElement(".browse"); // The browse button
    this.uploadEl = fEl.getElement(".upload"); // The upload button (starts upload)
    this.finishEl = fEl.getElement(".finish"); // The finish button (showed after upload)
    this.cancelEl = fEl.getElement(".cancel"); // The cancel selection button
    
    this.statusEl = fEl.getElement(".status"); // The div that contains the total-files and total-size status
    this.blankListEl = fEl.getElement(".blank"); // The blank slate element (OPTIONAL)
    this.totalFilesEl = fEl.getElement(".total-files"); // The total files to upload indicator (OPTIONAL)
    this.totalSizeEl = fEl.getElement(".total-size"); // The total size in kB to upload indicator (OPTIONAL)
    this.messagesEl = fEl.getElement(".messages"); // The messages panel (OPTIONAL)
    
    this.uploadEl.addEvent("click",function(e){
      (new Event(e)).stop();
      base.startUpload();
    });    
    
    this.cancelEl.addEvent("click", function(e){
      (new Event(e)).stop();
      base.cancelSelect();
    });
    
    this.finishEl.addEvent("click", function(e){
      (new Event(e)).stop();
      base.finishUpload();
    });
    
    this.reset();
  },
  
  // Set a status message.
  setMessage : function(msg){
    if(this.messagesEl){
      this.messagesEl.set("html",msg);
    }
  },
  
  reset : function(){
    this.statusEl.setStyle("display", "");
    this.cancelEl.setStyle("display", "");
    this.uploadEl.setStyle("display", "");    
    this.finishEl.setStyle("display", "none");
    
    this.browseEl.setStyle("visibility", "visible");
    this.setMessage("");
    this.update();
  },
  
  // Call once update is complete
  uploadCompleted : function(){
    this.statusEl.setStyle("display", "none");
    this.cancelEl.setStyle("display", "none");
    this.uploadEl.setStyle("display", "none");    
    this.finishEl.setStyle("display", "");
    
    this.browseEl.setStyle("visibility", "hidden");
  },
  
  // Update bytecounts
  update : function(){
    
    // Blank slate cleanup
	  if(this.blankListEl){ 
      if(this.base.files.length === 0){
        this.blankListEl.removeClass("hide");
      } else {
        this.blankListEl.addClass("hide");
      };	      	    
	  }
    
    if(this.totalFilesEl){
      this.totalFilesEl.set("html", this.base.files.length);
    }
    
    if(this.totalSizeEl){
      this.totalSizeEl.set("html", this.base.formatSize(this.base.size));
    }    
  },  
  
  hide : function(){
    this.containerEl.addClass("hide");
  },
  
  show : function(){
    this.containerEl.removeClass("hide");    
  }  
});

Application.UploadProgress = new Class({
  initialize : function(base, containerEl){
    var fEl = this.containerEl = $(containerEl);
    this.base = base;
    this.progressBarEl = fEl.getElement(".progressbar")
    
    // Initialize setters.
    this.setters.each(function(fun,fName){
      var el = fEl.getElement(fun[0]);
      
      if(el){
        this[fName] = fun[1].pass(el,this);
      } else {
        this[fName] = $empty;
      }
    },this);    
    
    this.cancelEl = fEl.getElement(".cancel");
    if(this.cancelEl){
      this.cancelEl.addEvent("click",function(){
        base.stopUpload();
      });
    }    
    
  },
  
  // Reset to base state.
  reset : function(){
    
  },
  
  
  uploadStarted : function(){
    this.updateTotalFiles();
    this.updateTotalSize();
    this.updateCurrentFile();
    this.updateCurrentPercentage();
    this.updateCurrentSize();
    this.updateProgressBar();       
  },
  
  // Update progress
  update : function(file){
    this.currentFile = file;
    this.updateCurrentFile();
    this.updateCurrentPercentage();
    this.updateCurrentSize();
    this.updateProgressBar();   
  },
  
  hide : function(){
    this.containerEl.addClass("hide");
  },
  
  show : function(){
    this.containerEl.removeClass("hide");    
  },
  
  // Setters (only called if there actually is an element that matches)
  setters : $H({
    updateTotalFiles  : [".total-files", function(el){ 
      el.set("html", this.base.files.length); 
    }],
    updateTotalSize   : [".total-size" , function(el){ 
      el.set("html", this.base.formatSize(this.base.size)); 
    }],
    updateCurrentFile : [".current-file", function(el){ 
      el.set("html", this.base.progress.uploaded + this.base.progress.failed);
    }],
    updateCurrentPercentage : [".current-percentage", function(el){ 
      el.set("html", this.base.progress.percent + "%"); 
    }],
    updateCurrentSize : [".current-size", function(el){ 
      el.set("html", this.base.formatSize(((this.base.progress.percent / 100) * this.base.size).toInt())); 
    }],
    updateProgressBar : [".progressbar .bar", function(el){ 
      el.setStyle("width", this.base.progress.percent + "%"); 
    }]
  })
  
});

// Handle UI & Interaction for file queue
Application.UploadFile = new Class({
  initialize : function(base, info){
    this.base = base;
    
    this.fileName = info.name;
    this.fileId = info.id;
    this.fileSize = info.size;
  },
  
  // Resets view state to base
  reset : function(){
    this.element.removeClass("failed");
    this.element.removeClass("success");    
    this.removeEl.setStyle("display", "inline");
    this.infoEl.set("html", "");
  },
  
  // Render upload success
  uploadSuccess : function(){
    this.reset();
    this.element.addClass("success");
    this.removeEl.setStyle("display", "none");
  },
  
  // Render upload failure
  uploadFailure : function(error){
    this.reset();
    this.element.addClass("failed");
    this.removeEl.setStyle("display", "none");
    if(error){
      this.infoEl.set("html", error);
    }
  },
  
  // Remove this file from the list
  remove : function() {
    this.element.destroy();
  },
  
  // Renders the file in the list.
  render : function(){
    this.infoEl = new Element('span', {'class': 'info'});
    this.removeEl =  new Element('a', {
			'class': 'remove',
			href: '#',
			html: "X",
			title: "X",
			events: {
				click: function() {
					this.remove();
          this.base.removeFile(this);
					return false;
				}.bind(this)
			}
		});
		
		this.element = new Element('li').adopt(
		    new Element("span",{"class": "name", "html" : this.fileName}),
  			new Element('span', {'class': 'size', 'html': " (" + this.base.formatSize(this.fileSize) + ") "}),
  			this.removeEl,
  			this.infoEl
		).inject(this.base.uploadBrowser.listEl);    
  }
  
});