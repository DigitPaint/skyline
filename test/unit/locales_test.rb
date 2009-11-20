require 'test_helper'

class Skyline::LocalesTest < ActiveSupport::TestCase
  context "The locale files" do
    setup do
      @original_load_path = I18n.load_path.dup
      @origignal_locale = I18n.locale
      I18n.load_path = I18n.load_path.select{|p| (p =~ /vendor\/plugins\/skyline/)}
      I18n.backend = I18n::Backend::Simple.new
      
      @standard_locale = :"nl-NL"
      @other_locales = I18n.available_locales.select{|l| l.to_s =~ /^[a-z]{2}-[A-Z]{2}$/}
      @other_locales -= [@standard_locale]
    end

    should "should all have all entries" do
      I18n.locale = @standard_locale
      standard = I18n.translate("")
      
      @other_locales.each do |l|
        I18n.locale = l
        other = I18n.translate("")
        
        missing_keys = differences(standard, other)
        if missing_keys.any?
          puts "\n" + "-" * 80
          puts "\nMissing translations in language file: #{l.to_s}"
          print_differences(missing_keys)
          puts "\n\n1: one entry is missing"
          puts "*: complete subtree is missing"
          puts "\n" + "-" * 80
        end
        assert_equal missing_keys.size, 0

        missing_keys = differences(other, standard)
        if missing_keys.any?
          puts "\n" + "-" * 80
          puts "\nObsolete translations in language file: #{l.to_s}"
          print_differences(missing_keys)
          puts "\n\n1: one entry is obsolete"
          puts "*: complete subtree is obsolete"
          puts "\n" + "-" * 80
        end
        assert_equal missing_keys.size, 0
      end
    end            
    
    teardown do
      I18n.load_path = @original_load_path
      I18n.backend = I18n::Backend::Simple.new
      I18n.locale = @origignal_locale
    end
  end

  def differences(standard, other)
    missing = {}
    standard.keys.each do |k|
      if standard[k].kind_of?(Hash)
        if other[k]
          d = differences(standard[k], other[k])
          missing[k] = d if d.any?
        else
          missing[k] = "*"
        end
      else
        missing[k] = "1" unless other.keys.include?(k)
      end
    end        
    missing
  end
  
  def print_differences(missing_keys, indent = 2)
    missing_keys.each do |k, v|
      if v.kind_of?(String)
        puts v + " " * indent + k.inspect
      else
        puts " " + " " * indent + k.inspect
        print_differences(v, indent + 2)
      end
    end
  end
end