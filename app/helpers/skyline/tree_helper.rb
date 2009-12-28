# @private
module Skyline::TreeHelper
  
  def page_tree(pages, roots, options = {})
    node_content = Proc.new do |page|
      css_class = case
        when page["locked"] == "1" then "locked"
        when page.published? && page.identical_to_publication? then "published"
        when page.published? then "changed"
        else nil
      end      
      content_tag("span", page.title, :class => css_class)
    end
    
    node_title = Proc.new do |page|
      page.title
    end
    
    node_url = Proc.new do |page|
      edit_skyline_article_path(page["id"])
    end
    
    options.reverse_merge! :id_prefix => "article", :node_content => node_content, :node_url => node_url, :node_title => node_title
    node_tree(pages,roots,options)
  end
  
  def media_dir_tree(dirs,roots,options={})
    node_content = Proc.new do |node|
      content_tag("span",node.name)
    end
    
    node_title = Proc.new do |node|
      node.name
    end
        
    node_url = Proc.new do |node|
      skyline_media_dir_media_files_path(node)
    end
    options.reverse_merge! :id_prefix => "media", :node_content => node_content, :node_url => node_url, :node_title => node_title
    node_tree(dirs,roots,options)    
  end
  
  
  def node_tree(node_collection,nodes,options={})
    node_url = Proc.new{|node| "" }
    node_content = Proc.new{|node| node }
    node_title = Proc.new{|node| "" }
    options.reverse_merge! :id_prefix => "node", :node_content => node_content, :node_url => node_url, :node_title => node_title, :selected => nil
    tags = []
    nodes ||= []
    
    nodes.each do |node|
      selected = options[:selected].present? ? options[:selected].id == node.id : false
      li = link_to(options[:node_content].call(node), options[:node_url].call(node), :class => (selected ? "selected" : nil), :title => options[:node_title].call(node))
      li << node_tree(node_collection,node_collection[node.id],options) if node_collection.has_key?(node.id)
      node_class = node.open ? "open" : "closed" if node_collection.has_key?(node.id)
      tags << content_tag("li",li , :id => "#{options[:id_prefix]}_#{node.id}", :class => node_class)
    end
    
    content_tag("ul",tags.join("\n"));
  end
  
end