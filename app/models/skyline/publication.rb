# @private
class Skyline::Publication < Skyline::ArticleVersion
  belongs_to :variant, :class_name => "Skyline::Variant"
  
  default_scope :order => "created_at DESC"
  scope :with_variant, {:conditions => "variant_id IS NOT NULL"}
  
  def published?
    self.article.published_publication == self
  end
  
  # variant_attributes: an Hash of attributes for a new Variant
  # required: variant_attributes[:name]
  #
  def rollback(variant_attributes)
    raise ArgumentError, "variant_attributes must be an Hash" unless variant_attributes.kind_of?(Hash)
    raise ArgumentError, "variant_attributes['name'] expected" unless variant_attributes.include?('name')
    
    variant = self.clone_to_class(self.article.variants)
    variant.attributes = variant_attributes      
    variant.variant_id = nil
    variant.save
    variant
  end
end
