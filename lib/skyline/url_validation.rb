# Usage: 
# class Model < ActiveRecord::Base
#   extend Skyline::UrlValidation
#   validates_format_of_url :field
# end
# --
# Ripped from: http://gist.github.com/102138
# --

require 'uri/http'

module Skyline::UrlValidation
  # Validates whether the value of the specified attribute matches the format of an URL,
  # as defined by RFC 2396. See URI#parse for more information on URI decompositon and parsing.
  #
  # This method doesn't validate the existence of the domain, nor it validates the domain itself.
  #
  # Allowed values include http://foo.bar, http://www.foo.bar and even http://foo.
  # Please note that http://foo is a valid URL, as well http://localhost.
  # It's up to you to extend the validation with additional constraints.
  #
  # class Site < ActiveRecord::Base
  # validates_format_of :url, :on => :create
  # validates_format_of :ftp, :schemes => [:ftp, :http, :https]
  # end
  #
  # ==== Configurations
  #
  # * <tt>:schemes</tt> - An array of allowed schemes to match against (default is <tt>[:http, :https]</tt>)
  # * <tt>:message</tt> - A custom error message (default is: "is invalid").
  # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
  # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
  # * <tt>:on</tt> - Specifies when this validation is active (default is <tt>:save</tt>, other options <tt>:create</tt>, <tt>:update</tt>).
  # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
  # occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The
  # method, proc or string should return or evaluate to a true or false value.
  # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
  # not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
  # method, proc or string should return or evaluate to a true or false value.
  #
  def validates_format_of_url(*attr_names)

    configuration = { :on => :save, :schemes => %w(http https) }
    configuration.update(attr_names.extract_options!)

    allowed_schemes = [*configuration[:schemes]].map(&:to_s)

    validates_each(attr_names, configuration) do |record, attr_name, value|
      begin
        uri = URI.parse(value)

        if !allowed_schemes.include?(uri.scheme)
          raise(URI::InvalidURIError)
        end

        if [:scheme, :host].any? { |i| uri.send(i).blank? }
          raise(URI::InvalidURIError)
        end

      rescue URI::InvalidURIError => e
        record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
        next
      end
    end
  end
end