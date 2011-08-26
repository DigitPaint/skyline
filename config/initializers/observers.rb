unless ( File.basename($0) == "rake" && ARGV.include?("skyline:db:migrate") )
  ActiveRecord::Base.observers = [
    "Skyline::FileCacheSweeper", 
    "Skyline::ArticleVersionObserver"
  ]
end