//= require <Swiff.Uploader>
/*
  Class: Skyline.Uploader
  An extended version of Swiff.Uploader. It has some extra event's and
  default behaviour.
  
  Events:
  updateStatus    - Some status needs to be updated (removal of file or selection)
  completeSuccess - Triggered if all files were successfully uploaded.
  completeFailure - Triggered if some files did not complete successfully (stopped not included)
*/
Skyline.Uploader = new Class({
	Extends: Swiff.Uploader,
	options: {
		queued: true,
		verbose: false
	},
	initialize : function(options){
    if(!options){options = {};}
    if(!options.fileClass){ options.fileClass = Skyline.Uploader.File; }
		
		this.parent(options);
				
    this.addEvents({
      "complete" : this._onComplete,
      "fileStop" : this._onFileStop,
      "fileRemove" : this._updateStatus,      
      "queue" : this._updateStatus,
      "load" : this._onLoad,
      "fail" : this._onFail
    });
    		
	},
	
	_updateStatus: function(){
	  this.fireEvent("updateStatus");
  },
	
  // Events
  _onFileStop : function(){
    this.fileList.each(function(file){
      if(file.status == Swiff.Uploader.STATUS_QUEUED || file.status == Swiff.Uploader.STATUS_RUNNING){
        file.stop();
      }
    });
  },
  _onComplete : function(){
    var invalids = this.fileList.filter(function(el){
      return el.status != 3;
    });
    //  All files have successfully been uploaded
    if(invalids.length === 0){
      this.fireEvent("completeSuccess");
    } else {
      this.fireEvent("completeFailure");
    }
  },
  
  // Triggered when the Flash loaded fine.
  _onLoad : function(){
    // Relay interactions from overlayed flash to browse button
    this.target.addEvents({
      click: function(){ return false; },
      mousedown: function(){ this.focus(); }
    });
  },
    
  // An error occured with the flash file.
  _onFail : function(error){
		switch (error) {
			case 'hidden': // works after enabling the movie and clicking refresh
				alert('To enable the embedded uploader, unblock it in your browser and refresh (see Adblock).');
				break;
			case 'blocked': // This no *full* fail, it works after the user clicks the button
				alert('To enable the embedded uploader, enable the blocked Flash movie (see Flashblock).');
				break;
			case 'empty': // Oh oh, wrong path
				alert('A required file was not found, please be patient and we fix this.');
				break;
			case 'flash': // no flash 9+ :(
				alert('To enable the embedded uploader, install the latest Adobe Flash plugin.');
		}
  }
	  
});

Skyline.Uploader.File = new Class({
  Extends: Swiff.Uploader.File,
  initialize : function(){
    this.addEvents({
      "complete" : this._onComplete    
    });
    this.parent.apply(this,arguments);
  },
  _onComplete: function(){
    if(this.status === Swiff.Uploader.STATUS_ERROR){
      this.fireEvent("failure");
    } else if(this.status === Swiff.Uploader.STATUS_COMPLETE){
      var status = JSON.decode(this.response.text, true);
      if(status && status["status"]){
        this.response.json = status;        
        this.response.code = status["status"];      
        if(status["status"] == 200){
          this.fireEvent("success");
        } else {
          this.fireEvent("failure");
        }
      } else {
        // We don't know and assume the status 200 mean's it's ok
        this.fireEvent("success");
      }
    }

  }
});