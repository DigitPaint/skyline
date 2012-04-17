# Module to help with on the fly reordered elements in a form
# accepts_nested_attributes_for is a great helper, but can't handle reordering of the elements (and saving the new position)
# 
# So, here comes the solution. It includes two parts: a helper method in the FormBuilderWithErros and this Module
#
# Example view:
#
#   <%= article_form.fields_for "sections_attributes", section, :index => guid do |s| %>
#     <%= s.hidden_field :id unless s.object.new_record? %>
#     <%= s.hidden_field :_destroy, :class => "delete" %>
#     <%= s.positioning_field %>
#     ...
#   <% end %>
#
# This will result in param attributes like {"article" => {"sections_attributes" => {"674" => ..., "425" => ..., "256" => ...}, 
#                                                          "sections_position" => ["256", "674", "425"]}}
# NB: 674, 425 and 256 are the indexes (or guids)
# The key "sections_position" is added with the help of positioning_field and states the wanted order of the sections (the order 
# is the order in which the elements of the form were when the form was posted - so they could've been moved around by the user).
#
# 
# Without use of this module this will result in an error: "unknown attribute: sections_position", so we include the module in our 
# Article(!) Class (well actually in Skyline it should be in the Variant class, but I use article_form here to keep the example 
# short)
# This module triggers on associations that have been configured with accepts_nested_attributes_for.
#
# class Skyline::Article < Skyline::ArticleVersion
#   include NestedAttributesPositioning
#   accepts_nested_attributes_for :sections
#   ....
# end


module NestedAttributesPositioning
  def self.included(base)
    base.extend(ClassMethods)
    base.send :cattr_accessor, :accepts_nested_attributes_for_associations
    base.send :accepts_nested_attributes_for_associations=, []
    base.send :alias_method_chain, :assign_attributes, :positioning
  end
      
  module ClassMethods
    def accepts_nested_attributes_for(*attr_names)
      super
      attr_names.extract_options!
      self.accepts_nested_attributes_for_associations += attr_names
    end
  end
  
  def assign_attributes_with_positioning(new_attributes, options = {})
    a = new_attributes.dup
    self.accepts_nested_attributes_for_associations.map{|association| handle_positioning_for_association(association, a)}
    self.assign_attributes_without_positioning(a)
  end
  
  def handle_positioning_for_association(association, attributes)
    positions = attributes.delete("#{association}_position")
    if positions.andand.kind_of?(Array)
      attributes_hash = attributes.delete("#{association}_attributes")
      sorted_attributes = []
      positions.each_with_index do |index, position|
        attributes_hash[index][:position] = position
        sorted_attributes << attributes_hash[index]
      end
    
      self.assign_attributes_without_positioning({"#{association}_attributes" => sorted_attributes})
      self.send(association).sort!{|a,b| a.position <=> b.position}
    end
  end
end
