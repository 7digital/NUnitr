root_dir = File.expand_path(File.dirname(__FILE__))
$: << root_dir
$: << File.join(root_dir, 'nunitr')
$: << File.join(root_dir, 'nunitr', 'support')

Dir.glob(File.join(root_dir, '**/*.rb')).each {|file| require file }
