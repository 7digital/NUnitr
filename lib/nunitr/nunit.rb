include Rake::DSL

class NUnit

	attr_accessor :teamcity_nunit_version, :nuget_nunit_version
	
	def initialize()
		@teamcity_nunit_version = 'v4.0 x86 NUnit-2.5.3'
		@nuget_nunit_version = '2.6.0.12051'				
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
			sh "./tools/nuget.exe install Nunit.Runners -o ./tools -Version #{@nuget_nunit_version}"
			return Dir.glob("./tools/*#{@nuget_nunit_version}/**/nunit-console.exe").last
		end
		
		return "#{ENV['teamcity.dotnet.nunitlauncher']} #{@teamcity_nunit_version}"
	end
end

class TestFilesNotFound < StandardError  
end 

class ConfigFileNotFound < StandardError  
end 
