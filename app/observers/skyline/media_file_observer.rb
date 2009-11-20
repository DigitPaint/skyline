class Skyline::MediaFileObserver < ActiveRecord::Observer
  def after_save(media_file)
    index(media_file)
  end
  
  def index(media_file)
    return unless %w{pdf word excel powerpoint}.include?(media_file.file_type)
    indexer = Skyline::Indexer.instance
    solr_id = "#{media_file.class.name}-#{media_file.id}"
    
    fields = {"ext.literal.id" => solr_id,
              "ext.literal.title" => "#{media_file.title}", 
              "ext.literal.url" => "#{media_file.url}",
              "ext.literal.cat" => "#{media_file.class.name}",
              "ext.literal.documentdate" => Time.now.to_time.utc.iso8601(3),
              "ext.literal.tags_multi" => media_file.tags.collect{|t| t.tag},
              "ext.literal.description_s" => media_file.description,
              "ext.literal.file_type_s"=>media_file.file_type,
              "ext.idx.attr" => "true",
              "ext.def.fl" => "body",
              "stream.file" => "#{media_file.file_path}"}
                
	  indexer.add_file_index(fields)
  end
  
  def after_destroy(media_file)
    indexer = Skyline::Indexer.instance
    solr_id = "#{media_file.class.name}-#{media_file.id}"
    
    indexer.remove_from_index(solr_id)
  end
end