//= require <uploader>

/*
  Class: Application.LibraryUploader
  Implements the specific upload widget for Skyline.
*/
Application.LibraryUploader = new Class({
  Extends: Skyline.Uploader,
  options: {
    path: "/skyline/javascripts/src/skyline/vendor/fancyupload/Swiff.Uploader.swf"
  },
  initialize : function(formId,options){
    this.formEl = $(formId);
    var fEl = this.formEl.getElement(".upload-files");
    var pEl = this.formEl.getElement(".upload-progress");
    
    this.uploadBrowser = new Application.UploadBrowser(this,fEl);
    this.uploadProgress = new Application.UploadProgress(this,pEl);  
    
    var options = options || {};
    options.target = this.uploadBrowser.browseEl;
    options.url = this.formEl.action;
    options.fileClass = Application.UploadFile;
    
    this.addEvents({
      "load" : this.onInit,
      "updateStatus" : this.onUpdateStatus,
      "start" : this.onStartUpload,
      "completeSuccess" : this.onCompleteSuccess,
      "completeFailure" : this.onCompleteFailure,      
      "complete" : this.onCompleteUpload,
      "fileStart" : this.onUpdateProgress,
      "fileComplete" : this.onUpdateProgress,
      "fileProgress" : this.onUpdateProgress
    });    
    this.parent(options);
  },
  
  // Reset the uploader to beginstate.
  reset : function(){
    this.onInit();
    this.remove();
  },
  
  // Events
  onInit : function(){
    this.uploadBrowser.browseEl.setStyle("visibility","visible");
    this.uploadBrowser.uploadEl.setStyle("visibility","visible");    
    this.box.setStyle("visibility","visible");  
    this.uploadBrowser.show();
    this.uploadProgress.hide();
  },
  onUpdateStatus : function(){
    this.uploadBrowser.update();
  },
  onStartUpload : function(){
    this.uploadBrowser.hide();
    this.uploadProgress.show();  
    this.uploadProgress.start();
  },
  onCompleteUpload : function(){
    this.uploadBrowser.show();
    this.uploadProgress.hide();
    this.uploadBrowser.browseEl.setStyle("visibility","hidden");
    this.box.setStyle("visibility","hidden");
  },
  onCompleteSuccess : function(){
    this.uploadBrowser.setMessage(this.options.allUploadedMessage);
  },
  onCompleteFailure : function(){
    this.uploadBrowser.setMessage(this.options.someUploadedMessage);          
  },
  onUpdateProgress : function(file){
    this.uploadProgress.update(file);
  }
});

Application.UploadBrowser = new Class({
  initialize : function(base,containerEl){
    var fEl = this.containerEl = $(containerEl);
    this.base = base;
    
    this.listEl = fEl.getElement("ul.files");  // The file list
    this.browseEl = fEl.getElement(".browse"); // The browse button
    this.uploadEl = fEl.getElement(".upload"); // The upload button (starts upload)
    
    this.blankListEl = fEl.getElement(".blank"); // The blank slate element (OPTIONAL)
    this.totalFilesEl = fEl.getElement(".total-files"); // The total files to upload indicator (OPTIONAL)
    this.totalSizeEl = fEl.getElement(".total-size"); // The total size in kB to upload indicator (OPTIONAL)
    this.messagesEl = fEl.getElement(".messages"); // The messages panel (OPTIONAL)
    
    this.uploadEl.addEvent("click",function(){
      base.start();
      return false;
    });    
  },
  setMessage : function(msg){
    if(this.messagesEl){
      this.messagesEl.set("html",msg);
    }
  },
  update : function(){
    // Blank slate cleanup
	  if(this.blankListEl){ 
      if(this.base.size === 0){
        this.blankListEl.removeClass("hide");
      } else {
        this.blankListEl.addClass("hide");
      };	      	    
	  }
    
    if(this.totalFilesEl){
      this.totalFilesEl.set("html",this.base.fileList.length);
    }
    if(this.totalSizeEl){
      this.totalSizeEl.set("html",Swiff.Uploader.formatUnit(this.base.size,"b"));
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
  initialize : function(base,containerEl){
    var fEl = this.containerEl = $(containerEl);
    this.base = base;
    
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
        base.stop();
      });
    }
    
  },
  start : function(){
    this.updateTotalFiles();
    this.updateTotalSize();    
  },
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
  
  setters : $H({
    updateTotalFiles  : [".total-files", function(el){ el.set("html",this.base.fileList.length); }],
    updateTotalSize   : [".total-size" , function(el){ el.set("html",Swiff.Uploader.formatUnit(this.base.size,"b")); }],
    updateCurrentFile : [".current-file", function(el){ el.set("html", this.base.fileList.indexOf(this.currentFile) + 1 );}],
    updateCurrentPercentage : [".current-percentage", function(el){ el.set("html",this.base.percentLoaded + "%"); }],
    updateCurrentSize : [".current-size", function(el){ el.set("html", Swiff.Uploader.formatUnit(this.base.bytesLoaded, 'b')); }],
    updateProgressBar : [".progressbar .bar", function(el){ el.setStyle("width",this.base.percentLoaded + "%"); }]
  })
});

Application.UploadFile = new Class({
  Extends: Skyline.Uploader.File,
  render : function(){
		if (this.invalid) {
			this.remove();
			return;
		}
    
		this.addEvents({
      'success' : this.onSuccess,
      'failure' : this.onFailure,
      'stop' : this.onStop,
      'remove': this.onRemoveFile // Don't call this onRemove (it conflicts with internal onRemove)
		});    
    
    this.infoEl = new Element('span', {'class': 'info'});
    this.removeEl =  new Element('a', {
			'class': 'remove',
			href: '#',
			html: "X",
			title: "X",
			events: {
				click: function() {
					this.remove();
					return false;
				}.bind(this)
			}
		});
		
		this.element = new Element('li').adopt(
		    new Element("span",{"class": "name", "html" : this.name}),
  			new Element('span', {'class': 'size', 'html': " (" + Swiff.Uploader.formatUnit(this.size, 'b') + ") "}),
  			this.removeEl,
  			this.infoEl
		).inject(this.base.uploadBrowser.listEl);
  },
  // Events
  onFailure : function(){
    this.element.removeClass("success");        
    this.element.addClass("failed");
    if(this.response.code == 422){
      if(this.response.json && this.response.json.errors){
        this.infoEl.set("html", this.response.json.errors["file"]);
      }
    } 
    this.removeEl.destroy();          
  },
  onSuccess : function(){
    this.element.removeClass("failed");
    this.element.addClass("success");
    this.removeEl.destroy();    
  },
  onStop : function(){
    this.remove();
  },
	onRemoveFile: function() {
	  this.element.destroy();
	}  
});