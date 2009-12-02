# Use this module in all content models that need to be indexed and searchable by Solr
#
# Usage: 
# class Model < ActiveRecord::Base
#   include Skyline::SearchableItem
#
#   searchable_field :title => :title,
#                    :body => :body,
#                    :documentdate => :publication_date,
#                    :url => :url,
#                    :theme_s => :theme_title,
#                    :year_i => :publication_year
#
#   [indexer_option :if => :published_publication_id_changed?]
# end
#
# 
# 1) Gives your Model the following interface:
# 
#    class  Model < ActiveRecord::Base
#      after_save :add_index
#      after_destroy :remove_from_index
#
#      self << class
#        def searchable_field(fields)
#      end
#    end

module Skyline::SearchableItem
	
	def self.included(base)
 		base.extend(ClassMethods)
		base.send(:after_save, :add_index)
		base.send(:after_destroy, :remove_from_index)
		base.send(:cattr_accessor, :searchable_fields)
		base.send(:cattr_accessor, :indexer_options)
		base.send(:indexer_options=, {})
	end
 	
 	module ClassMethods
 		# Method to add fields from the model to the solr index
 		# ==== Parameters
 		# fields<Hash>::hash of fields as 
 		# field => solr-field
 		#
 		# ==== Options
 		# if field is symbol then the value of the field is indexed
 		# if field is a string then the string itself is indexed
 		# if field is a Proc, the result of calling the Proc (with myself as argument) is indexed
 		#
 		# 							solr-field must be pressent in solr configuration
 		def searchable_field(fields)
 			self.searchable_fields ||= {} 			
 			fields.each do |sf, f|
        self.searchable_fields.merge!(sf => f)
      end
 		end
 		
 		# Method to set options for the indexer
 		# ==== Parameters
 		# options<Hash>::
 		# 
 		# ==== Options
 		# :if            a method or lambda function which should return true for the indexing process to continue
 		def indexer_option(options)
 		  self.indexer_options = options
 		end
 	end
 	
  def solr_typecast(v)
    case v
    when ActiveSupport::TimeWithZone, Date, Time, DateTime
      v.to_time.utc.iso8601(3)
    when String
      ActionController::Base.helpers.strip_tags(v)
    else
      v
    end
  end
 	
 	# Return the solr id
 	def solr_id
		solr_id = "#{self.class.name}-#{self.id}"
	end
	
	# create hash for solr from self.searchable_fields
	# ==== Returns
	# Hash:: hash with solr_field => value pairs
	def hash_searchable_fields
		hash = {}
		self.searchable_fields.each do |sf, f|
		  value = case f.class.name
		          when "Proc"
		            f.call(self)
		          when "String"
		            f
		          else
		            self.send(f)
		          end
	    hash[sf] = solr_typecast(value)			
		end
  	hash.merge!({:id => self.solr_id, :cat => self.class.name})
	end
	
	# Add/Update solr index
 	def add_index
 	  return unless self.evaluate_if_option
 	  
 	  indexer = Skyline::Indexer.instance	
 	  if (self.class.publishable? && self.published?) || !self.class.publishable?
		  indexer.add_index(hash_searchable_fields)
		else
		  indexer.remove_from_index(self.solr_id)
		end
	end
		
	# Remove item from solr-index
	def remove_from_index
		indexer = Skyline::Indexer.instance
		indexer.remove_from_index(self.solr_id)
	end
 		
	def evaluate_if_option
	  return true unless self.indexer_options.has_key?(:if)
	  return case self.indexer_options[:if].class.name
           when "Proc"
             self.indexer_options[:if].call(self)
           else
             self.send(self.indexer_options[:if])
           end
  end
end