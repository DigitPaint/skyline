ActiveRecord::Base.observers = [
  "Skyline::FileCacheSweeper", 
  "Skyline::ArticleVersionObserver"
]
