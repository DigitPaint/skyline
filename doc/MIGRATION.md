Skyline Version Migration
=========================

General update recipe
---------------------

After every Skyline update make sure that:

* You have updated your `Gemfile`, or the `config.gem` specifications in your `environment.rb`.
* Run `rake skyline:db:migrate` to update your Skyline tables.
* Run `rake skyline:db:seed` to update roles/rights and other important data updates.
* **Plugin users only!** The assets (`RAILS_ROOT/public/skyline`) are from the new version. If they are symlinked, Skyline will 
  take care of them for you.

Version 3.0.7 -> Version 3.0.8
------------------------------

There are no pressing changes you need to make to your implementation. Keep in mind however
that we deprecated some methods. The deprecated methods will be removed in version 3.1.0

**page\_sections\_per_column** in templates. Use `sections_per_column` instead. The old method
is still available as an alias.

**setting and page\_from\_settings** in templates. These two helpers are deprecated
in favour of `Settings.get` for `setting` and `Settings.get_page` for `page_from_setting`. The
method signatures are identical was merly a restructuring.

First OS release -> Version 3.0.7
---------------------------------

**1. Template changes: render.peek_until** Peek until doesn't skip forward in the collection 
anymore. The old behaviour was inconsistent with peek. All peek functions now only look forward.
Replace all occurences of `var = peek_until...` and make sure they manually do `skip!(var.size)`
a better sollution is to use `render_until`.

**2. Template changes: @Page\_class** `@Page_class` is no longer accesible in the renderer. Use
`site.root` if you need to access the root class.

**3. Template changes: Renderer partials** You no longer need to pass the currently rendererd object
to partials. You can access the currently rendered object by using `renderer.object`.

**3. Custom sections: Buttons are no longer images** The helpers `button_image` has been removed
and the syntax of `submit_button` and `submit_button_to` has changed. Search for occurences of one 
of these three helpers and replace them accordingly:

**button_image**

    link_to button_image("small/delete.gif", :alt => :delete), ...
    
to

    link_to button_text(:delete), ..., :class => "button small red"
    
**submit\_button\_to**

    submit_button_to "small/delete.gif", ..., :value => :delete
    
to

    submit_button_to :delete, ..., :class => "small red"
    
**submit\_button**

    submit_button "small/delete.gif", ..., :value => :delete

to

    submit_button :delete, ..., :class => "small red"
    
