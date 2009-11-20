class Skyline::Indexer
  include Singleton
  
  # Add/Update solr index
 	def add_index(fields)
 	  if Skyline::Configuration.solr_indexing
		  solr = RSolr.connect						
		  solr.add(fields)
		  solr.commit
		end
	end
		
	# Remove item from solr-index
	def remove_from_index(solr_id)
	  if Skyline::Configuration.solr_indexing
		  solr = RSolr.connect
		  solr.delete_by_id(solr_id)
		  solr.commit
		end
	end
	
	def add_file_index(fields)
	  if Skyline::Configuration.solr_indexing
	    solr = RSolr.connect
	    begin
	      solr.send_request('/update/extract',fields)
	      solr.commit
      rescue RSolr::RequestError
      end
	  end
  end
end
