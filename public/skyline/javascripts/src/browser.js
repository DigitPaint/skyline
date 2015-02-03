Application.Browser = new Class({
  Extends: Skyline.RemoteDialog,
  initialize : function(params){
    if(params.common){
      this.setOptions({width: 800, height: 500});
    } else {
      this.setOptions({width: 800, height: 400});
    }
    this.requestClass = Application.Request.HTML;
    this.params = params;
    this.parent(arguments[1]);
    this.addEvent("close",this._onClose.bind(this));
    this.addEvent("loaded",this.setupLayout.bind(this));
  },
  select : function(){
    var values = this.serialize();
    this.close();
    this.fireEvent("select",[values]);
    this.destroy();    
  },
  
  cancel : function(){    
    this.close();
    this.fireEvent("cancel");
    this.destroy();
  },
  
  _onClose : function(){
    this.fireEvent("cancel");
    this.destroy();    
  },  
  
  serialize : function(){
    if(this.commonPanel) {
      return $merge(this._serializeContainer(this.commonPanel.element), this._serializeContainer(this.tabs.activeTab.windowEl));
    } else {
      return this._serializeContainer(this.tabs.activeTab.windowEl);
    }
  },
  
  setupLayout : function(){
    var d = this.contentEl.getElement(".dialog"), tp, tw;
    this.layout = new Skyline.VerticalLayout(d);

    tp = this.layout.addPanel(d.getElement(".tabPanel"), {height:"content"});
    
    this.tabs = new Skyline.Tabs();
    
    var tabElements = tp.element.getElements("li");
    var tabWindows = d.getElements("div.window");
    var commonPanel = d.getElement(".commonPanel");
    var tabOptions = {height: 300, layout: "horizontal", hidden:true};
    if(!commonPanel){
      tabOptions = {height: null, layout: "horizontal", hidden:true};
    }
    
    tabElements.each(function(el,i){
      var t = this.tabs.addTab(el,tabWindows[i]);
      this.fireEvent("addTab",[t]);
      this.layout.addPanel(tabWindows[i],tabOptions);
    }.bind(this));
    
    if(commonPanel){
      this.commonPanel = this.layout.addPanel(commonPanel);
    }
    this.layout.addPanel(d.getElement(".footerPanel"), {height:"content"});      
    
    this.tabs.addEvent("activateTab",function(control,tab){
      if(control.previouslyActiveTab){ 
        control.previouslyActiveTab.windowEl.retrieve("skyline.layout").hide();
      }
      var l = tab.windowEl.retrieve("skyline.layout");
      l.show();
    }.bind(this));
      
    this.layout.setup();
    this.tabs.setup();    
  },

  _serializeContainer  : function(element){
    if(!element){ return {}; }
    var values = {}, t = this;
    element.getElements('input, select, textarea', true).each(function(el){
      if (!el.name || el.disabled || el.type == 'submit' || el.type == 'reset' || el.type == 'file'){ return; }
      var value = (el.tagName.toLowerCase() == 'select') ? Element.getSelected(el).map(function(opt){
        return opt.value;
      }) : ((el.type == 'radio' || el.type == 'checkbox') && !el.checked) ? null : el.value;
      $splat(value).each(function(val){
        if (typeof val != 'undefined') {
          values[t._extract_name(el.name)] = val;
        }
      });
    });
    return values;    
  },
  
  _extract_name : function(name){
    return name.replace(/browser\[(.+)\]/,"$1");
  }

});


$extend(Application.Browser,{
  browseLinkFor : function(section){
    this.browseFor(section,Application.LinkBrowser,arguments[1]);    
  },
  browseContentFor : function(section){
    this.browseFor(section,Application.ContentBrowser,arguments[1]);
  },
  browseImageFor : function(section){
    this.browseFor(section,Application.ImageBrowser,arguments[1]);
  },
  browseFileFor : function(section){
    this.browseFor(section,Application.FileBrowser,arguments[1]);
  },
  browseMediaNodeFor : function(section){
    this.browseFor(section,Application.MediaNodeBrowser,arguments[1]);
  },
  browsePageFor : function(section){
    this.browseFor(section,Application.PageBrowser,arguments[1]);
  },
  
  /*
    Function: unlink
    Unlink the element. Clears input.referable_type
  */
  unlink : function(element){
    var element = $(element);
    var relatesTo;
    
    element.set("class","")
    
    element.getElement("input.referable_type").set("value","");
    element.getElement("input.referable_id").set("value","");
    element.getElement("span.referable_title").set("html","");
    
    var rDelete = element.getElement("input.referable_delete") || element.getElement("input.delete");
    rDelete.set("value","1");
    
    if(relatesTo = element.getElement("div.relatesTo")){
      relatesTo.removeClass('linked');
    }
    
  },
  
  /*
    Function: browseFor
    Simple browse method, works by getting elements by class name.
    The container must contain at least:
     - input.referable_type
     - input.referable_id
    
    Parameters:
    
    element - The container element
    browser - The browser Class to use (default = Application.LinkBrowser)
  
  */
  browseFor : function(element, browser){
    if(!browser){ var browser = Application.LinkBrowser; }
    var options = arguments[2] || {};
    var dialogParams = {};
    
    if (options['dialogParams']) {
      dialogParams = options['dialogParams'];
      delete options['dialogParams'];
    }
    
    var liClass, element = $(element);
    var relatesTo = element.getElement("div.relatesTo");
    var rTEl = element.getElement("input.referable_type");
    var rIEl = element.getElement("input.referable_id");
    var rTitleEl = element.getElement("span.referable_title");
    var ltEl = element.getElement("input.link_title");
    var lcuEl = element.getElement("input.link_custom_url");
    var rDelete = element.getElement("input.referable_delete") || element.getElement("input.delete");
    
    dialogParams.referable_type = rTEl.get("value");
    dialogParams.referable_id = rIEl.get("value");
    
    if(lcuEl){
      dialogParams.url = lcuEl.get("value");
    }
    
    var dialog = new browser(dialogParams);
      
    dialog.addEvent("select",function(values){
      if (values.referable_type && values.referable_type !== "Skyline::ReferableUri") {
        rTEl.set("value",values.referable_type);
        rIEl.set("value",values.referable_id);
        if(rTitleEl){ rTitleEl.set("html",values.referable_title); }
        if(lcuEl){ lcuEl.set("value",""); }
        
        // Setting class
        liClass = Application.rubyClassToCssClass(values.referable_type);
        if(values.file_type){ liClass += " " + values.file_type; }
        element.set("class",liClass);
      } else {
        rTEl.set("value","Skyline::ReferableUri");
        rIEl.set("value","");
        if(lcuEl){ lcuEl.set("value",values.url); }
        if(rTitleEl){ rTitleEl.set("html",values.url);}
        element.set("class","external");
      }
      
      if(ltEl && ltEl.get("value").trim() === ""){
        ltEl.set("value",values.referable_title || values.url);
      }
      
      if(relatesTo){
        relatesTo.addClass("linked");
      }
      
      if(rDelete){
        rDelete.set("value",0);
      }
      
    });
    dialog.open();    
  }
})


Application.ImageBrowser = new Class({
  Extends : Application.Browser,
  url : "",
  initialize : function(params){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/browser/images";
    this.addEvent("select", function(values){
      if (values.url) {
        values.url = Application.sanitizeUrl(values.url);
      }
    });
    this.parent(params);
  }
});

Application.LinkBrowser = new Class({
  Extends : Application.Browser,
  url : "",
  initialize : function(params){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/browser/links";
    
    if(params.common && params["new"]){
      this.addEvent("addTab",function(tab){
        var id = tab.windowEl.get("id");
        if(id == "browserExternalLink" || id == "browserMediaLibrary"){
          var bTargetEl = this.contentEl.getElement(".browser_target");
          var bTargetOptions =  bTargetEl.getElements("option").map(function(el){return el.get("value");});
          tab.addEvent("activate",function(tab){
            tab.origTargetIdx = bTargetEl.selectedIndex;
            bTargetEl.selectedIndex = bTargetOptions.indexOf("_blank");
          });
          tab.addEvent("deactivate",function(tab){
            if(tab.origTargetIdx){
              bTargetEl.selectedIndex = tab.origTargetIdx;
            }
          });        
        }
      }.bind(this));
    }
    this.addEvent("select", function(values){
      if (values.url) {
        values.url = Application.sanitizeUrl(values.url);
      }
    });
    this.parent(params);
  }
});

Application.ContentBrowser = new Class({
  Extends : Application.Browser,
  url : "",
  initialize : function(params){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/browser/content";
    this.parent(params);
  }
});

Application.PageBrowser = new Class({
  Extends : Application.Browser,
  url : "",
  initialize : function(params){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/browser/pages";    
    this.parent(params);
  }
});

Application.FileBrowser = new Class({
  Extends : Application.Browser,
  url : "",
  initialize : function(params){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/browser/files";    
    this.parent(params);
  }
});

Application.MediaNodeBrowser = new Class({
  Extends : Application.Browser,
  url : "",
  initialize : function(params){
    // We have to set the URL here, because the Application.urlPrefix is not available at
    // load time.
    this.url = Application.urlPrefix + "/browser/media_nodes";    
    this.parent(params);
  }
});