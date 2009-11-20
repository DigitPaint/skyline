namespace :skyline do

  desc 'Run all unit, functional and integration tests'
  task :test do
    errors = %w(skyline:test:units skyline:test:functionals skyline:test:integration).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.to_sentence(:locale => :en)}!" if errors.any?
  end
  
  namespace :test do
    Rake::TestTask.new(:units => [:environment,"db:test:prepare"]) do |t|
      base = File.join(File.dirname(__FILE__), "..")
      t.libs << (base + "/test")
      t.pattern =  base + '/test/unit/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:units'].comment = "Run the unit tests in test/unit"

    Rake::TestTask.new(:functionals => "db:test:prepare") do |t|
      base = File.join(File.dirname(__FILE__), "..")      
      t.libs << (base + "/test")
      t.pattern =  base + '/test/functional/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:functionals'].comment = "Run the functional tests in test/functional"

    Rake::TestTask.new(:integration => "db:test:prepare") do |t|
      base = File.join(File.dirname(__FILE__), "..")      
      t.libs << (base + "/test")
      t.pattern =  base + '/test/integration/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:integration'].comment = "Run the integration tests in test/integration"    
  end
end