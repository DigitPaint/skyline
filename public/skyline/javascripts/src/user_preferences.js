/* 
  Class: Application.UserPreferences
  The UerPreferences sets a cookie with the preferences and checks if the cookie ddoes not exceed 4kb.
  If the cookie is too big then an Ajax request is made to store the preference. The stored userpreference cookie
  is sent with the request and handled in the middleware
  
  Configuration:
  url - The URL to send AJAX request to (MUST BE SET!).
*/
Application.UserPreferences = {  
  url : "",
  userPreferences : $H({"_delete" : []}),
    
  set: function(key, value){
    if (value == "_delete") {
      this.userPreferences.erase(key);
      this.userPreferences["_delete"].include(key);
    } else {
      this.userPreferences[key] = value;
      this.userPreferences["_delete"].erase(key);
    }
      
    var cookie_value = JSON.encode(this.userPreferences);
    
    if (cookie_value.length > 4096) {
      if (value == "_delete") {
        this.userPreferences["_delete"].erase(key);
      } else {
        this.userPreferences.erase(key);
      }
      
      Cookie.write("skyline_up", JSON.encode(this.userPreferences), {path: "/"});
      
      var new_preference = new Hash();
      new_preference[key] = value;
      
      var postvars = {};
      postvars[rails.csrf.param] = rails.csrf.token;
      postvars['skyline_up'] = JSON.encode(new_preference);
      
      // We don't want to use the Application.Request here because this is a background operation
      // and should not show a wait state.      
      var cookieRequest = new Request.JSON({
                            url: this.Url,
                            onSuccess: function(up){
                              this.userPreferences.empty();
                            }.bind(this)
                          }).post(postvars);
    } else {
      Cookie.write("skyline_up", cookie_value, {path: "/"});
    }
  },
  remove : function(key){
    this.set(key, "_delete");
  }
};