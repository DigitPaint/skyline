class TestSearchable < ActiveRecord::Base
	include Skyline::SearchableItem
	
	searchable_field :title => :title, :body => :body
end
