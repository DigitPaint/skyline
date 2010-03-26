class Skyline::UserPreference < ActiveRecord::Base
  set_table_name :skyline_user_preferences
  
  belongs_to :user, :class_name => "Skyline::User"
  
  class << self
    def set(key, value)
      raise ArgumentError.new("Cannot put hash into a value") if !parent_is_hash?(key)
      prefs = flatten_preferences({key => value})

      prefs.each do |k, v|
        joined_key = "#{k.join('.')}."
        self.delete_all("`#{self.table_name}`.`key` LIKE '#{joined_key}%'")
        self.create(:key => joined_key, :encoded_value => v.to_yaml)
      end
    end
    
    def get(key)
      user_preferences = self.find(:all, :conditions => "`#{self.table_name}`.`key` LIKE \"#{key}.%\"")
      
      return nil unless user_preferences.any?
      user_preferences.size == 1 && user_preferences.first.key == "#{key}." ? user_preferences.first.value : expand_preferences(user_preferences, key)
    end
    
    def has_key?(key)
      self.exists?(["`#{self.table_name}`.`key` LIKE ?", "#{key}.%"])
    end
    
    def remove(key)
      self.delete_all("`#{self.table_name}`.`key` LIKE '#{key}.%'")
    end
        
    private
    def flatten_preferences(rest, cur_key = [])
      rest.inject({}) do |acc, (k, v)|
        if v.kind_of?(Hash)
          # append key
           acc.merge!(flatten_preferences(v, cur_key + [k]))
        else
          # set value
          acc[cur_key + [k]] = v
        end
        acc
      end
    end
    
    def expand_preferences(preferences, query_key)    
      preferences.inject({}) do |acc, p|
        acc.merge!(p.key.sub(/#{query_key}./,"").split(".").reverse.inject(p.value) { |mem, var| {var => mem} })
        acc
      end
    end
    
    def parent_is_hash?(key)
      key_array = key.split(".")
      key_array.pop
      return true if key_array.empty?
      
      !self.exists?(["`#{self.table_name}`.`key` LIKE ?", "#{key_array.join('.')}."])
    end
  end
  
  #return unserialized value
  def value()
    return ::YAML.parse(self.encoded_value).transform
  end
end
