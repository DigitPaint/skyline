module Skyline::TranslationHelper

  # Extended translate function
  # ==== Parameters 
  # key<Symbol,String>:: the key (same as parameter to translate function)
  # options<Hash>:: options(same as parameter to translate function)
  #   this function supports a Class in the options[:scope], ie:
  #        tx(:ueber, :scope => [Skyline::Page, :flashes])
  #     will try to translate this for Skyline::Page and all its parent classes (all descendants from AR)
  #     first try:                  translate(:ueber, :scope => [:page, :flashes])
  #     if that fails, it'll try:   translate(:ueber, :scope => [:article, :flashes])
  #     (note that the Skyline module is stripped)
  #   if no Class is found, we'll fallback on the super function
  #
  # ==== Returns
  # <String>:: the translation
  def t(key, options = {})
    klass = options[:scope] && options[:scope].kind_of?(Array) && options[:scope].detect{|s| s.kind_of?(Class)}
    return super unless klass

    klass_index = options[:scope].index(klass)
    options[:raise] = true
    
    klass.self_and_descendants_from_active_record.map do |superklass|
      begin
        o = options.dup
        o[:scope][klass_index] = superklass.name.underscore.sub(/^skyline\//, "")
        return I18n.translate(key, o)
      rescue I18n::MissingTranslationData => e
      end
    end
    
    super    
  end
  
end
