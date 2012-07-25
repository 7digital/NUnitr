# encoding: utf-8

require 'rubygems'
require 'bundler'

begin
	Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
	$stderr.puts e.message
	$stderr.puts "Run `bundle install` to install missing gems"
	exit e.status_code
end

require 'rake'
require 'jeweler'
Jeweler::Tasks.new do |gem|
	gem.name = 'nunitr'
	gem.homepage = 'https://github.com/7digital/NUnitr'
	gem.license = 'MIT'
	gem.summary = %Q{Build tasks for .Net projects}
	gem.description = %Q{Find and tokenise files!}
	gem.email = 'rob.beal@7digital.com'
	gem.authors = ['Robert Beal']
	gem.files = FileList['{lib}/**/*']
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
	sh 'rm -rf coverage/*' if ENV['COVERAGE']
	t.pattern = 'spec/**/*_spec.rb'
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
	version = File.exist?('VERSION') ? File.read('VERSION') : ''
	rdoc.rdoc_dir = 'rdoc'
	rdoc.title = 'rakeoff #{version}'
	rdoc.rdoc_files.include('README*')
	rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Run the tests'
task :default => :spec

desc 'Release a new version of the app to RubyGems'
task :cut do
	sh 'rake gemcutter:release'
end
