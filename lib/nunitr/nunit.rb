include Rake::DSL

class NUnit

	attr_accessor :nunit_runner, :teamcity_nunit_version
	
	def initialize()
		@teamcity_nunit_version = 'v4.0 x86 NUnit-2.5.3'				
	end

	def run(pattern, environment=nil)
		glob_pattern = "**/[b][i][n]/Release/#{pattern}.dll"
		dlls = Dir.glob(glob_pattern)
		raise TestFilesNotFound, "No tests found for pattern #{glob_pattern}" if dlls.empty?

		if !environment.nil?
			dlls.each do |dll| 
				config = File.dirname(dll) + "/App.#{environment}.config"
				raise ConfigFileNotFound, "Config file #{config} not found" if !File.exists?(config)
				sh "copy #{config} #{dll + '.config'}".gsub('/', '\\') 
			end	
		end

		sh "#{runner} #{dlls.join(' ').strip}"		
	end
	
	def runner
		if ENV['teamcity.dotnet.nunitlauncher'].nil?
			sh './tools/nuget.exe install Nunit.Runners -o ./tools'
			nunit = Dir.glob('./tools/**/nunit-console.exe').last
		else
			nunit = "#{ENV['teamcity.dotnet.nunitlauncher']} #{@teamcity_nunit_version}"
		end	
		
		nunit
	end
end

class TestFilesNotFound < StandardError  
end 

class ConfigFileNotFound < StandardError  
end 
