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
  user_preferences : $H({"_delete" : []}),
    
  set: function(key, value){
    if (value == "_delete") {
      this.user_preferences.erase(key);
      this.user_preferences["_delete"].include(key);
    } else {
      this.user_preferences[key] = value;
      this.user_preferences["_delete"].erase(key);
    }
      
    var cookie_value = JSON.encode(this.user_preferences);
    
    if (cookie_value.length > 4096) {
      if (value == "_delete") {
        this.user_preferences["_delete"].erase(key);
      } else {
        this.user_preferences.erase(key);
      }
      
      Cookie.write("skyline_up", JSON.encode(this.user_preferences), {path: "/"});
      
      var new_preference = new Hash();
      new_preference[key] = value;
      var cookieRequest = new Request.JSON({
                            url: this.Url,
                            onSuccess: function(up){
                              this.user_preferences.empty();
                            }.bind(this)
                          }).post({'skyline_up': JSON.encode(new_preference)});
    } else {
      Cookie.write("skyline_up", cookie_value, {path: "/"});
    }
  }
};