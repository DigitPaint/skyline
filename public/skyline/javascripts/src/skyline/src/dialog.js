/*
  Class: Skyline.Dialog
*/
Skyline.Dialog = new Class({
  Implements: [Options,Events],
  options : {
    width: 200,
    height: 200,
    blocker : Skyline.Blocker,
    blockerOpacity : 0.5
  },
  /*
    Constructor: initialize
  */
  initialize: function(options){
    this.setOptions({blocker : Skyline.Blocker}); // Doesn't work in the options above 'cause of load order
    this.setOptions(options);
    
    // Prebind position event.
    this._onPosition = this._position.bind(this);
    this._create();
  },
  /*
    Function: update(content)
    Updates the content window with HTML.
  */
  update: function(content){
    this.setContent(content);
  },
  /*
    Function: show()
    Show the window
  */
  show : function(){
    this.options.blocker.show(this.options.blockerOpacity);
    this.windowEl.setStyle("display", "block");
    
    var sizes = this.getSize();
    this.titleBarEl.setStyle("width",sizes.x);    
    this._position();
    this._attachEvents();
    this.focus();
  },
  hide : function(){
    this.windowEl.setStyle("display", "none");
  },
  close : function(){
    this.options.blocker.hide();
    this.hide();
    this._detachEvents();
    this.fireEvent("close");    
    if(Skyline.Dialog.current == this){
      Skyline.Dialog.current = null;
    }
  },
  
  destroy : function(){
    this.windowEl.dispose();
  },
  
  focus : function(){
    this.fireEvent("focus");
    Skyline.Dialog.current = this;
    // TODO
  },
  setTitle : function(title){
    this.title = true;
    this.titleEl.set("html",title);    
  },
  setContent : function(content){
    this.content = true;
    if($type(content) == "element"){
      this.contentEl.empty();
      this.contentEl.adopt(content);
    } else {
      this.contentEl.set("html",content);
      content.stripScripts(true);
    }
  },
  getSize : function(){
    return this.contentEl.getSize();
  },
  setup : function(){
    if(this.options.width){
      this.contentEl.setStyle("width",this.options.width);
    }
    
    if(this.options.height){
      this.contentEl.setStyle("height",this.options.height);      
    }    
  },
  
  // Internal methods
  
  _attachEvents : function(){
    // Dragging
		this.drag = new Drag.Move(this.windowEl,{
		  handle: this.titleBarEl,
		  snap: 2
		});
		this.drag.addEvent("complete", function(){
		  var pos = this.windowEl.getPosition();
			this.windowPos = {
				x : pos.x - window.getScrollLeft(),
				y : pos.y - window.getScrollTop()
			};	
		}.bind(this));
		this.drag.addEvent("beforeStart", this._onBeforeStartDrag.bind(this));

    // Window resize
		window.addEvents({scroll: this._onPosition, resize: this._onPosition});    
		
    // Close
    this.closeEl.addEvent("click", this.close.bind(this));
  },
  
  _detachEvents : function(){
    this.closeEl.removeEvent("click",this.close.bind(this));
		window.removeEvents({scroll: this._onPosition, resize: this._onPosition});    
		this.drag.detach();
  },
  
  _onBeforeStartDrag : function(){
    var xLimit, yLimit, lScroll = window.getScrollLeft(), tScroll = window.getScrollTop(), size;
    
    size = this.windowEl.getSize();
    xLimit = [lScroll,lScroll + window.getWidth() - size.x];
    yLimit = [tScroll,tScroll + window.getHeight() - size.y];
    
    
    this.drag.setOptions({
      limit: {x: xLimit, y: yLimit}
    });
  },
  _position : function(){
    var pos = {};
		if(!this.windowPos){
      var size = this.windowEl.getSize();		  
      
			// Center the window
		  pos.top = (window.getHeight() - size.y)/2;
			pos.left = (window.getWidth() - size.x)/2;
		} else {
		  pos.top = this.windowPos.y;
		  pos.left = this.windowPos.x;		  
		};
		
    // Correct for scrolling
  	pos.top =  window.getScrollTop() + pos.top;
  	pos.left = window.getScrollLeft() + pos.left;

		
		this.windowEl.setStyles(pos);
  },
  
  // <div id="theDialog" class="dialog">
  //   <div class="head"><div class="rightShadow"><div class="leftShadow"><div class="inner">
  //     The la header! 
  //     <div class="controls">
  //       <a href="#"><img src="../assets/dialog/button-close.gif" alt="X" /></a>
  //     </div>
  //   </div></div></div></div>
  //   <div class="body"><div class="shadow"><div class="inner">
  //     The Boddeh!
  //   </div></div></div>
  //   <div class="bottomShadow">
  //     <div class="leftShadow">&nbsp;</div>
  //     <div class="middleShadow">&nbsp;</div>
  //     <div class="rightShadow">&nbsp;</div>
  //     </div>
  //   </div>
  // </div>  
  _create : function(){
    this.windowEl = new Element("div", {"class" : "dialog"});
    
    this.titleBarEl = new Element("div",{"class" : "inner"});
    this.titleEl = new Element("span", {"class" : "title", "html": "&nbsp;"}); 
    this.closeEl = new Element("a", {"class" : "close", "href" : "#", "html" : "X"});
    this.contentEl = new Element("div", {"class" : "inner","html": "&nbsp;"});
    
    
    this.windowEl.adopt(
      new Element("div", {"class" : "head"}).adopt(
        new Element("div",{"class" : "rightShadow"}).adopt(
          new Element("div",{"class" : "leftShadow"}).adopt(
            this.titleBarEl.adopt(
              this.titleEl,
              new Element("div",{"class" : "controls"}).adopt(
                this.closeEl
              )
            )
          )
        )
      ),
      new Element("div", {"class" : "body"}).adopt(
        new Element("div", {"class" : "shadow"}).adopt(
          this.contentEl.setProperty("class","inner")
        )
      ),
      new Element("div", {"class" : "bottomShadow"}).adopt(
        new Element("div", {"class" : "leftShadow", "html" : "&nbsp;"}),
        new Element("div", {"class" : "middleShadow", "html" : "&nbsp;"}),
        new Element("div", {"class" : "rightShadow", "html" : "&nbsp;"})
      )
    );
    
    this.windowEl.setStyle("display", "none");
    this.windowEl.inject(document.body);
    this.contentEl.store("skyline.dialog",this);
  }
});

Skyline.Blocker = {
	visible : false,
	// Pas in an opacity value for the background.
	show : function(opacity){
		if(this.visible){ return false; }
		
		this.create();
		this.element.setStyles({opacity: (opacity ? opacity : 0.8), display: "block"});
    this.iframe.setStyle("display","block");
		this.setup(true);
		this.visible = true;
		
	},
	hide : function(){
		if(!this.element){return false;}
		this.element.setStyle("display","none");
    this.iframe.setStyle("display","none");		
		this.setup(false);
		this.visible = false;
	},
	setup : function(open){
		if (Browser.Engine.trident && !window.XmlHttpRequest  || Browser.Engine.gecko && Browser.Engine.version <= 18){
      // alert("going there");
  		var fn = open ? 'addEvent' : 'removeEvent';
  		window[fn]('scroll', this.setPositionEvent);
  		window[fn]('resize', this.setPositionEvent);
			this.setPosition();
		}
	},
	// Set position and size to full window
	setPosition : function(){
	  var size = window.getSize();
		var coords = {position: "absolute", top: window.getScrollTop(),left:window.getScrollLeft(), height: size.y , width: size.x}; 
		this.element.setStyles(coords);
		this.iframe.setStyles(coords);
	},	
	create : function(){
		if(!this.element){
			this.element = new Element("div").setProperty('id', 'overlay').injectInside(document.body);
			// Pre-bind the function so we can use it as eventhandler
			this.setPositionEvent = this.setPosition.bind(this); 
			this.iframe = new Element("iframe").setProperties({
			  id: "overlayiframe",
				src: "javascript:'';", 
				marginwidth: 0, 
				marginheight: 0, 
				align: "bottom",
				scrolling: "no",
				frameborder: 0}).setStyles({
					display: "none",
					filter: "alpha(opacity=0)"
				});
			this.iframe.injectInside(document.body);			
			this.element.injectInside(document.body);
		}
	}
};

Skyline.RemoteDialog = new Class({
  Extends: Skyline.Dialog,
  url: "",
  open : function(){
    var req, url = this.url, t = this;
    if(arguments[0]){
      url = arguments[0];
    }
    this.setup();    
    this.show();
    this.setContent("Loading");
    this.setTitle("Loading...");

    var rC = this.requestClass || Request.HTML;

    req = new rC({url: url, method: "get", data : $H(this.params).toQueryString(), evalScripts : false});
    req.addEvent("success",function(tree,elements,html,js){
      t.setContent(html);
      $exec(js);
      this.fireEvent("loaded");
    }.bind(this));
    req.send();
  }  
});