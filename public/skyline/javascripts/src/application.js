// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require "mootools_on_rails"

var Application = {};

//= require "utils"
//= require "draggable_files"
//= require "library_uploader"
//= require "page_helper"
//= require "messages"
//= require "browser"
//= require "sections"
//= require "poller"

Application.LayoutSettings = {
  focusElement : null // The element to focus on domReady
};

Application.Layout = (function(){
  
  var A = Application;
  var Settings = A.LayoutSettings;
  
  var Layout = new Class({
  
    initialize : function(){
      if(Layout.current){ return; }
      Layout.current = this;
      
      this.layout = new Skyline.VerticalLayout("application");
      this.layout.addPanel("headerArea", {height: "content"});
      this.messageArea = this.layout.addPanel("messageArea", { layout: "horizontal", height: "content"});    
      this.contentArea = this.layout.addPanel("contentArea", { layout: "horizontal"});
      
      var initStack = $A([]);
      
      // Content area
      this.leftPanel = this.contentArea.addPanel("leftPanel", {layout: "vertical", width: 200, optional: true});
      if(this.leftPanel){
        this.contentArea.addSplitter();
        initStack.push("leftPanel");
      }
      
      this.contentPanel = this.contentArea.addPanel("contentPanel", {layout: "vertical"});
      initStack.push("contentPanel");     
      this.contentArea.addSplitter();

      this.metaPanel = this.contentArea.addPanel("metaPanel", { layout: "vertical", width: 150, optional: true});      
      if(this.metaPanel){
        initStack.push("metaPanel");
      }

      initStack.each(function(name){
        var fn = "initialize" + name.capitalize();
        if(this[fn] && this[name]){
          this[fn](this[name]);
        }
      }.bind(this));

      this.layout.setup();

      this._attachEvents();
      this._initializeUiComponents();
    },
    
    // Sub initializations.
    initializeLeftPanel : function(panel){
      var subPanels = $A([]);
      panel.element.getChildren("dt").each(function(dt){
        var dd = dt.getNext("dd");
        if(dd){
          subPanels.push([
            panel.addPanel(dt,{height: "content"}),
            panel.addPanel(dd,{})
          ]);
        }
      });
      
      
      if(subPanels.length > 1){
        var tabs = new Skyline.Tabs();
        subPanels.each(function(t){ 
          tabs.addTab(t[0].element,t[1].element);
        });
        
        tabs.addEvent("activateTab",function(control,tab){
          tab.windowEl.retrieve("skyline.layout").show();
        });
        tabs.addEvent("deactivateTab", function(control,tab){
          tab.windowEl.retrieve("skyline.layout").hide();
        });
        tabs.setup();        
      }
    },
    
    initializeContentPanel : function(panel){
      panel.addPanel("contentHeaderPanel", {height: "content"});
      
      // Add all DD elements as panels and hide them (except the first)
      // We add the dd.contentFooterPanel manually later.
      var hidden = false;
      var tabPanels = [];
      panel.element.getChildren("dd").each(function(dd){
        if(dd.get("id") == "contentFooterPanel"){ return; }
        var p = this[dd.get("id")] = panel.addPanel(dd, {layout: "vertical", hidden: hidden});
        tabPanels.push(p);
        hidden = true;
      }.bind(this));
      
      this.contentFooterPanel = panel.addPanel("contentFooterPanel", {height: "content", optional: true});    

      if(this.contentBodyPanel){
        this.contentInfoPanel = this.contentBodyPanel.addPanel("contentInfoPanel", {height: "content", optional: true});
        this.contentBodyPanel.addPanel("contentEditPanel",{optional: true});
      }
    },
    
    initializeMetaPanel : function(panel){
      panel.addPanel("metaHeaderPanel", {height:"content"});
      panel.addPanel("metaBodyPanel");      
    },
    
    _initializeUiComponents : function(){
      // Advanced togglers
      $$('dl.advanced').each(function(e){
        new Skyline.Toggle(e.getElement("dt a"),e,{"class": "closed"});
      });

      // TODO: Currently hardcoded, should someday become something like $$('ul.sections')...
      if($('contentlist')){
        new Application.Sections("contentlist",{ scrollParent : "contentEditPanel" });
      }
      
      // TODO: Currently hardcoded
      if($('toggle_page_advanced')){
        $('toggle_page_advanced').retrieve('skyline.toggle').addEvent("toggle",function(){
          Application.Layout.current.contentBodyPanel.setup();
        });
      }      
      
    },
  
    _attachEvents : function(){
      window.addEvent("domready", function(){
        this.layout.element.setStyle('visibility',"visible");
        if(Settings.focusElement){
          $(Settings.focusElement).selectRange(0,10000);
        }
      }.bind(this));      
    }
  });
  
  // ================================
  // = Layout for all Content views =
  // ================================
  Layout.Content = new Class({
    Extends : Layout,
    initializeContentPanel : function(panel){
      this.parent(panel);

      if(this.contentPreviewPanel){
        this.contentPreviewPanel.addPanel("contentPreview");
      }

      if($("contentlist")){
        new Application.Sections("contentlist",{ scrollParent : "contentEditPanel" });
      }

      // Editor / Preview tabs
      if(this.contentFooterPanel){
        var tabEl = this.contentFooterPanel.element.getElement("ul.bottomtabs");
        if(tabEl){
          var tabs = new Application.PanelTabs(tabEl);
          if(tabs.tabsByElement.previewTabLink){
            tabs.tabsByElement.previewTabLink.addEvent("activate",function(tab){
              var iframe = tab.windowEl.getElement("iframe");
              if(iframe && iframe.get("data-url")){
                iframe.set("src",iframe.get("data-url"));
              }
            });
          }
        }
      }
    }
  });
  
  // =========================
  // = Layout for Media view =
  // =========================
  Layout.Media = new Class({
    Extends : Layout,

    initialize : function(){
      this.parent(arguments);
      this.initializeDirTree("dirtree");
      $('newDir').addEvent("click", this.createDir.bind(this));
    },

    initializeDirTree : function(id){
      if(this.tree){
        this.tree.reload();
        //Fire select event to open the active node
        this.tree.selectNode(null, this.tree.selectedNode);
        return;
      };

      var self = this;

      this.tree = new Skyline.Tree(id,{
  	    offsetParent: $(id).getOffsetParent(),      
        draggable: true,
        orderable: false,
        dragMarker: false,
        fixedRootNodes: true
      });

      this.tree.addEvent("select", function(event,link){
        if(event){ event.stop(); }

        new Request({ 
          evalScripts: true, 
          url: link.getProperty("href")
        }).get();
        return false;
      });

      /*Add move listener to send ajax request when a node is dropped*/
      this.tree.addEvent("move", function(branchEl,newParentEl,newPosition){
        var newParentId = Application.getId(newParentEl.get('id'));
        var id = Application.getId(branchEl.get('id'));
        new Request({ 
          evalScripts:true, 
          url: self.skylineMediaDirsPath + "/"+ id,
          data: 'authenticity_token='+encodeURIComponent(Application.formAuthenticityToken)+'&skyline_media_dir[parent_id]=' + newParentId,
          method: 'put'
        }).send();
        return false;
      });

      //Fire select event to open the active node
      this.tree.selectNode(null, this.tree.selectedNode);
    },

    initializeUploadPanel : function(dirPath){
   	  $('finishedbutton').setStyle('display','none');
      var innerPanel = new Skyline.Toggle($("libraryuploader").getElement(".head"),$("libraryuploader"));
     	innerPanel.addEvent("toggle",function(){ 
        this.uploadPanel.parent.setup();
      }.bind(this));

       // Setup the uploadPanel.
       this.uploadPanel.parent.setup();

   		var upl = new Application.LibraryUploader("libraryuploaderform",I18n.LibraryUploader);

   	  upl.addEvent("complete",function(){
   	    $('uploadstatus').destroy();
   	    $('cancelselect').destroy();
   	    $('uploadbutton').destroy();
   	    $('finishedbutton').setStyle('display','');
   	    $('finishedbutton').addEvent("click",function() {
   	      new Request({ 
   	          evalScripts:true, 
   	          url: dirPath,
   	          method: 'get'
   	   	  }).send();
   	   	  return false;
   	    });
   	    new Request({ 
   	       evalScripts:true, 
   	       url: dirPath,
   	       data: "listonly=true",
   	       method: 'get'
   	   	}).send();
   	  });

   	  $('cancelselect').addEvent('click', function() {
    		upl.remove(); // remove all files
    		innerPanel.toggle();
    		return false;
  		});
   	},

    createDir : function(){
      target_id = Application.getId(this.tree.selectedNode.getParent("li").get("id"));

      new Request({ 
        evalScripts: true,
        data: 'authenticity_token='+encodeURIComponent(Application.formAuthenticityToken)+'&parent_id='+target_id,
        url: this.skylineMediaDirsPath,
      	method: 'post'
      }).send();
    },

    initializeContentPanel : function(panel){
      this.parent(panel);

      this.uploadPanel = this.contentBodyPanel.addPanel("uploadPanel", {height: "content"});
      this.contentBodyPanel.addPanel("fileListPanel");    
    }
  });  
  
  Layout.current = null;
  
  return Layout;
})();


/*
  Class: Application.PanelTabs
  Class to create tabsets automatically based on the structure:
  
  <ul>
    <li>
      <a href="#" rel="PANELID">tabtitle</a>
    </li>
  </ul>
  
  The rel attribute specifies the ID of the panel to show when this tab is activated.
*/
Application.PanelTabs = new Class({
  Extends : Skyline.Tabs,
  initialize : function(element){
    this.element = $(element);
    this.tabsByElement = {};
    this.parent.apply(this,arguments);
    this.element.getElements("li a").each(function(el){
      var rel = el.get("rel");
      if(!rel || !$(rel)){ return; }
      
      this.tabsByElement[el.get("id")] = this.addTab(el,$(rel));
    }.bind(this));
    
    this.addEvent("activateTab",function(control,tab){
      tab.windowEl.retrieve("skyline.layout").show();
    });
    this.addEvent("deactivateTab", function(control,tab){
      tab.windowEl.retrieve("skyline.layout").hide();
    });
    this.setup();  
  }
});

// ====================================================================== //

Application.Layouts = {};
Application.Layouts.History = new Class({
  initialize : function(element){
    var tp,sp,pp,list,t = this;
    this.layout = new Skyline.VerticalLayout(element);
    this.form = this.layout.element;
    
    tp = this.topPanel = this.layout.addPanel(element.getElement(".topPanel"), { layout:"horizontal"} );
    this.footerPanel = this.layout.addPanel(element.getElement(".footerPanel"), { height: "content" });
    
    sp = this.selectionPanel = tp.addPanel(tp.element.getElement(".selectionPanel"),{layout: "vertical", width: 150});
    sp.addPanel(sp.element.getElement("dt"), {height: "content"});
    sp.addPanel(sp.element.getElement("dd"));    
    
    tp.addSplitter();
    
    pp = this.previewPanel = tp.addPanel(tp.element.getElement(".previewPanel"),{layout: "vertical"});
    pp.addPanel(pp.element.getElement("dt"), {height: "content"});
    var ppf = pp.addPanel(pp.element.getElement("dd"));
    this.iframe = ppf.element.getElement("iframe");
    ppf.addPanel(this.iframe);
    

    this.tabs = new Skyline.Tabs();
    
    sp.element.getElement("ul").getElements("li a").each(function(lnk){
      t.tabs.addTab(lnk,t.iframe);
    });
    
    this.tabs.addEvent("activateTab", function(tabs,tab){
      t.activate(tab.tabEl.get("class").replace(/^.*_/,""),tab.tabEl.get("href"));
    });
    
    
    this.disableForm = function(ev){ ev.stop(); ev.preventDefault(); };
    this.form.addEvent("submit",this.disableForm);
    this.formDisabled = true;
    this.button = this.footerPanel.element.getElement("button");    
    
    this.layout.setup();
    
  },
  activate : function(id,url){
    if(this.formDisabled && this.button){
      this.form.removeEvent("submit",this.disableForm);
      this.button.removeClass("disabled");
      this.button.addClass("green");
      this.button.set("disabled","");
      this.formDisabled = false;
    }
    
    this.iframe.src = url;
    this.form.set("action",this.rollbackUrl.replace("000",id));
    this.form.removeClass("unsubmittable");
  }
});