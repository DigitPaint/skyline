/*
---
description: A MooTools driver for the Ruby on Rails 3 unobtrusive JavaScript API.

license: MIT-style

authors:
- Kevin Valdek

requires:
  core/1.3: '*'

provides:
  - Rails 3 MooTools driver

...
*/

(function($) {

  window.rails = {
    /**
     * If el is passed as argument, events will only be applied to
     * elements within el. Otherwise applied to document body.
     */
    applyEvents: function(el) {
      var el = $(el || document.body);
      var applyE = function(selector, action, callback) {
        var name = action + ":relay(" + selector + ")";
        el.addEvent(name, callback);
      };

      applyE('form[data-remote=true]', 'submit', rails.handleRemote);
      applyE('a[data-remote=true], input[data-remote=true], button[data-remote=true]', 'click', rails.handleRemote);
      applyE('a[data-method][data-remote!=true], button[data-method][data-remote!=true]', 'click', function(e) {
        e.preventDefault();
        if(rails.confirmed(this)) {
          var form = new Element('form', {
            method: 'post',
            action: this.get('href') || this.get('data-url'),
            styles: { display: 'none' }
          }).inject(this, 'after');
          
          var methodInput = new Element('input', {
            type: 'hidden',
            name: '_method',
            value: this.get('data-method')
          });
          
          var csrfInput = new Element('input', {
            type: 'hidden',
            name: rails.csrf.param,
            value: rails.csrf.token
          });
          
          form.adopt(methodInput, csrfInput).submit();
        }
      });
      var noMethodNorRemoteConfirm = ':not([data-method]):not([data-remote=true])[data-confirm]';
      applyE('a' + noMethodNorRemoteConfirm + ',' + 'input' + noMethodNorRemoteConfirm, 'click', function() {
        return rails.confirmed(this);
      });
    },

    getCsrf: function(name) {
      var meta = document.getElement('meta[name=csrf-' + name + ']');
      return (meta ? meta.get('content') : null);
    },

    confirmed: function(el) {
      var confirmMessage = el.get('data-confirm');
      if(confirmMessage && !confirm(confirmMessage)) {
        return false;
      }
      return true;
    },

    disable: function(el) {
      var button = el.get('data-disable-with') ? el : el.getElement('[data-disable-with]');

      if(button) {
        var enableWith = button.get('value');
        el.addEvent('ajax:complete', function() {
          button.set({
            value: enableWith,
            disabled: false
          });
        });
        button.set({
          value: button.get('data-disable-with'),
          disabled: true
        });
      }
    },

    handleRemote: function(e) {
      e.preventDefault();

      if(rails.confirmed(this)) {
        this.request = new Request.Rails(this);
        rails.disable(this);
        this.request.send();
      }
    }
  };

  Request.Rails = new Class({

    Extends: Application.Request,

    initialize: function(element, options) {
      this.el = element;
      this.parent(Object.merge({
        method: this.el.get('method') || this.el.get('data-method') || 'get',
        url: this.el.get('action') || this.el.get('href')
      }, options));

      this.addRailsEvents();
    },

    send: function(options) {
      this.el.fireEvent('ajax:before');
      if(this.el.get('tag') == 'form') {
        this.options.data = this.el;
      } else {
        var d = {};
        d[rails.csrf.param] = rails.csrf.token;
        this.options.data = Object.merge(d, (this.options.data || {}));
      }
      this.parent(options);
      this.el.fireEvent('ajax:after', this.xhr);
    },

    addRailsEvents: function() {
      this.addEvent('request', function() {
        this.el.fireEvent('ajax:loading', this.xhr);
      });

      this.addEvent('success', function() {
        this.el.fireEvent('ajax:success', this.xhr);
      });

      this.addEvent('complete', function() {
        this.el.fireEvent('ajax:complete', this.xhr);
        this.el.fireEvent('ajax:loaded', this.xhr);
      });

      this.addEvent('failure', function() {
        this.el.fireEvent('ajax:failure', this.xhr);
      });
    }

  });

})(document.id);

window.addEvent('domready', function() {

  rails.csrf = {
    token: rails.getCsrf('token'),
    param: rails.getCsrf('param')
  };

  rails.applyEvents();
});
