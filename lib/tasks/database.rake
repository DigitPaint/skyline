namespace :skyline do
  
  namespace :db do
    
    desc "Migrate the skyline migrations" 
    task :migrate => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(Skyline.root + "db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      
      # Also seed plugins
      Rails.application.config.skyline_plugins_manager.plugins.each do |path, plugin|
        next unless plugin.migration_path
        
        puts "\n\n[PLUGIN] [#{plugin.name}] ============================="
        ActiveRecord::Migrator.migrate(plugin.migration_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      end      
      
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby      
    end

    desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.rollback(Skyline.root + 'db/migrate/', step)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    namespace :migrate do
      desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
      task :redo => :environment do
        if ENV["VERSION"]
          Rake::Task["skyline:db:migrate:down"].invoke
          Rake::Task["skyline:db:migrate:up"].invoke
        else
          Rake::Task["skyline:db:rollback"].invoke
          Rake::Task["skyline:db:migrate"].invoke
        end
      end
  
      desc 'Resets your database using your migrations for the current environment'
      task :reset => ["db:drop", "db:create", "db:migrate"]
  
      desc 'Runs the "up" for a given migration VERSION.'
      task :up => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        ActiveRecord::Migrator.run(:up, Skyline.root + "db/migrate/", version)
        Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end
  
      desc 'Runs the "down" for a given migration VERSION.'
      task :down => :environment do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
        raise "VERSION is required" unless version
        ActiveRecord::Migrator.run(:down, Skyline.root + "db/migrate/", version)
        Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
      end
    end

    
    desc "Run all seed files in Skyline.root/db/fixtures/**"
    task :seed => :environment do
      Dir[Skyline.root + "db/fixtures/*.rb"].each do |f|
        load f
      end
      
      # Also seed plugins
      Rails.application.config.skyline_plugins_manager.plugins.each do |path, plugin|
        puts "\n\n[PLUGIN] [#{plugin.name}] ============================="
        Dir[plugin.seed_path + "*.rb"].each do |f|
          load f
        end
      end
    end
    
  end
  
end