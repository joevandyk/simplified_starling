require 'fileutils'

starling_folder = File.dirname(__FILE__) + '/../../../config/starling'

FileUtils.mkdir starling_folder unless File.exist?(starling_folder)

%w( development test production ).each do |env|
  starling_config = File.dirname(__FILE__) + "/../../../config/starling/#{env}.yml"
  FileUtils.cp File.dirname(__FILE__) + '/files/config.yml.tpl', starling_config unless File.exist?(starling_config)
end

starling_initializer = File.dirname(__FILE__) + '/../../../config/initializers/starling.rb'

unless File.exist?(starling_initializer)
  FileUtils.cp File.dirname(__FILE__) + '/files/initializer.rb', starling_initializer
end