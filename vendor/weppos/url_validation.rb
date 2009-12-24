require 'uri/http'

# Provides proper RFC 2396 based URL validation for ActiveRecord models through `validates_format_of_url`.
# 
# @example Usage: 
# class Model < ActiveRecord::Base
#   extend Skyline::UrlValidation
#   validates_format_of_url :field
# end
# 
# @see http://gist.github.com/102138  http://gist.github.com/102138 for the original implementation.
module UrlValidation
  # Validates whether the value of the specified attribute matches the format of an URL,
  # as defined by RFC 2396. 
  #
  # This method doesn't validate the existence of the domain, nor it validates the domain itself.
  #
  # Allowed values include http://foo.bar, http://www.foo.bar and even http://foo.
  # Please note that http://foo is a valid URL, as well http://localhost.
  # It's up to you to extend the validation with additional constraints.
  #
  # @see URI#parse URI#parse for more information on URI decompositon and parsing.
  # 
  # @example Usage
  # class Site < ActiveRecord::Base
  #   validates_format_of :url, :on => :create
  #   validates_format_of :ftp, :schemes => [:ftp, :http, :https]
  # end
  #
  # @overload validates_format_of_url(*attr_names, options={})
  #   @param *attr_names [Symbol, String] Attributes to validate
  #   @option options :schemes [Array<Symbol>] ([:http, :https]) 
  #     An array of allowed schemes to match against
  #   @option options :message [String]  ("is invalid") 
  #     A custom error message
  #   @option options :allow_nil [Boolean] (false) 
  #     If set to true, skips this validation if the attribute is `nil`.
  #   @option options :allow_blank [Boolean] (false) 
  #     If set to true, skips this validation if the attribute is blank.
  #   @option options :on [Symbol] (:save) 
  #     Specifies when this validation is active (options are `:save`, `:create`, `:update<`).
  #   @option options :if [Proc, Symbol]
  #     Specifies a method, proc or string to call to determine if the validation should
  #     occur (e.g. `:if => :allow_validation`, or `:if => Proc.new { |user| user.signup_step > 2 }`). The
  #     method, proc or string should return or evaluate to a true or false value.
  #   @option options :unless [Proc, Symbol]
  #     Specifies a method, proc or string to call to determine if the validation should
  #     not occur (e.g. `:unless => :skip_validation`, or `:unless => Proc.new { |user| user.signup_step <= 2 }`). The
  #     method, proc or string should return or evaluate to a true or false value.
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