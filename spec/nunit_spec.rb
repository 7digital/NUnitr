require 'support/spec_helper'
require 'nunit'

shared_examples_for 'nunit' do	
	before(:each) do
		@nunit = NUnit.new
		@pattern = '**/*.UnitTests.dll'
				
		ENV['teamcity.dotnet.nunitlauncher'] = 'c:/teamcity/nunit.exe'				
	end
	
	def given_the_glob_returns(files)
		Dir.stubs(:glob).with("**/[b][i][n]/Release/#{@pattern}.dll").returns(files)
	end
end

describe NUnit do
	include_context 'nunit'

	context 'Given there are no test files found' do
		before(:each) do
			given_the_glob_returns([])
		end	
		
		it 'raises an exception' do
			expect{ @nunit.run(@pattern) }.to raise_error TestFilesNotFound
		end		
	end

	context 'Given there are config files to be copied' do
		before(:each) do
			given_the_glob_returns(['c:/src/MyApp.UnitTests.dll'])
		end	
		
		it 'replaces the application config with the environment config' do
			File.stubs(:exists?).with('c:/src/App.systest.config').returns(true)
			@nunit.expects(:sh).with("copy c:\\src\\App.systest.config c:\\src\\MyApp.UnitTests.dll.config")
			@nunit.expects(:sh).with('c:/teamcity/nunit.exe v4.0 x86 NUnit-2.5.3 c:/src/MyApp.UnitTests.dll')
			@nunit.run(@pattern, 'systest')
		end		
	end

	context 'Given a Team City test runner' do
		before(:each) do
			given_the_glob_returns(['c:/src/MyApp.UnitTests.dll'])
		end		

		it 'executes the Team City runner' do
			@nunit.expects(:sh).with('c:/teamcity/nunit.exe v4.0 x86 NUnit-2.5.3 c:/src/MyApp.UnitTests.dll')
			@nunit.run(@pattern)
		end
		
		it 'executes a specific version of the Team City runner' do
			@nunit.teamcity_nunit_version = 'v3.5 x64 2.6'
			@nunit.expects(:sh).with("c:/teamcity/nunit.exe #{@nunit.teamcity_nunit_version} c:/src/MyApp.UnitTests.dll")
			@nunit.run(@pattern)
		end
	end
	
	context 'Given a local test runner' do
		before(:each) do
			ENV.delete('teamcity.dotnet.nunitlauncher')  
			given_the_glob_returns(['c:/src/MyApp.UnitTests.dll'])
		end		
		
		it 'executes the local runner' do
			Dir.stubs(:glob).with("./tools/*2.6.0.12051/**/nunit-console.exe").returns(['c:/local/nunit.exe'])
			@nunit.expects(:sh).with('./.nuget/NuGet.exe install Nunit.Runners -o ./tools -Version 2.6.0.12051')
			@nunit.expects(:sh).with('c:/local/nunit.exe c:/src/MyApp.UnitTests.dll')
			@nunit.run(@pattern)
		end		
		
		it 'executes a specific version of the local runner' do
			Dir.stubs(:glob).with("./tools/*2.5/**/nunit-console.exe").returns(['c:/local/nunit.exe'])
			@nunit.nuget_nunit_version = '2.5'
			@nunit.expects(:sh).with('./.nuget/NuGet.exe install Nunit.Runners -o ./tools -Version 2.5')
			@nunit.expects(:sh).with('c:/local/nunit.exe c:/src/MyApp.UnitTests.dll')
			@nunit.run(@pattern)
		end		
	end
end
