require 'rubygems'
require 'sanitize'

# Use this module in all modules that have user input to sanitize this input before saving to database, ie, clean some or all html tags
# It adds the class method 'has_sanitizable_fields', which allows you to specify which fields to sanitize and optionally specify
# how to sanitize these fields.

# @see Skyline::HasManyReferablesIn Including this module automatically sanitizes all fields that have references.
# Use has_sanitizable_fields :field, false to cancel if desired

# @example Usage
#   class Model < ActiveRecord::Base
#     include Skyline::Sanitizer
#     
#     has_sanitizable_fields :field                     # Sanitize field with default configuration (see below)
#     has_sanitizable_fields :field, false              # Cancel sanitization for previously sanitized field
#     has_sanitizable_fields :field, :sanitize => :all  # Strip all html
#     has_sanitizable_fields :field1, field2            # Multiple fields are supported
#     has_sanitizable_fields :field, :sanitize =>       # Update default configuration with the option to completely remove all content from
#      Skyline::Sanitizer.default_config.merge(         #  specified tags (in this example, 'test<script>alert()</script>' would yield 'test')
#      :remove_contents => ['script'])
#     has_sanitizable_fields :field, :sanitize =>       # Sanitize field with custom configuration (see https://github.com/rgrove/sanitize/)
#       {:elements => ['a', 'span'],
#          :attributes => {'a' => ['href', 'title'], 'span' => ['class']},
#          :protocols => {'a' => {'href' => ['http', 'https', 'mailto']}
#
#   end

module Skyline::Sanitizer
  
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:before_save, :sanitize_fields)
    
    base.send(:class_attribute, :sanitizable_fields_with_options)
  end
  
  module ClassMethods
    
    def has_sanitizable_fields(*fields)      
      self.sanitizable_fields_with_options ||= {}
      options = fields.pop unless fields.last.kind_of? Symbol
      fields.each do |f|
        self.sanitizable_fields_with_options = self.sanitizable_fields_with_options.merge(f => options)
      end
    end
      
  end
  
  def sanitize_fields
    if self.sanitizable_fields_with_options.present?
      self.sanitizable_fields_with_options.each do |field, options|
        unless options == false
          if options.present? && options[:referable] == true
            self.send("#{field}=", Sanitize.clean(self.send("#{field}", true), default_config))
          else
            options = {:sanitize => default_config} if options.blank? || options[:sanitize].blank? || options[:sanitize] == :default
            if options[:sanitize] == :all
              self.send("#{field}=", Sanitize.clean(self.send("#{field}")))
            else
              self.send("#{field}=", Sanitize.clean(self.send("#{field}"), options[:sanitize]))
            end
          end
        end
      end
    end
  end
  
  # Default configuration for Sanitizer
  #
  # Only allow these tags:
  # a, b, br, caption, col, colgroup, div, em, i, li, ol, p, span, strong, sub, sup, table, tbody, td, tfoot, th, thead, tr, ul
  #
  # Only allow these protocols in a href attributes:
  # ftp, http, https, mailto, and relative URLs without a protocol
  #
  # Only allow these attributes for selected tags:
  #   all tags: dir, lang, title
  #   a: href, target
  #   col: span, width
  #   colgroup: span, width
  #   div: style
  #   ol: start, reversed, type
  #   span: style
  #   table: summary, width
  #   td: abbr, axis, colspan, rowspan, width
  #   th: abbr, axis, colspan, rowspan, scope, width
  #   ul: type
  def default_config
    {
      :elements => %w[
        a b br caption col colgroup div em i li
        ol p span strong sub sup table tbody td
        tfoot th thead tr ul img
      ],

      :attributes => {
        :all         => ['dir', 'lang', 'title', 'data-skyline-referable-type', 'data-skyline-referable-id', 'data-skyline-ref-id', 'class', 'id'],
        'a'          => ['href', 'target'],
        'col'        => ['span', 'width'],
        'colgroup'   => ['span', 'width'],
        'div'        => ['style'],
        'ol'         => ['start', 'reversed', 'type'],
        'span'       => ['style'],
        'table'      => ['summary', 'width'],
        'td'         => ['abbr', 'axis', 'colspan', 'rowspan', 'width'],
        'th'         => ['abbr', 'axis', 'colspan', 'rowspan', 'scope', 'width'],
        'ul'         => ['type'],
        'img'        => ['src', 'width', 'height', 'alt']
      },

      :protocols => {
        'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
      }      
    }
  end
  
  module_function :default_config
  
end