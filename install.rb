require 'fileutils'

starling_folder = File.dirname(__FILE__) + '/../../../config/starling'

FileUtils.mkdir starling_folder unless File.exist?(starling_folder)

%w( development test production ).each do |env|
  starling_config = File.dirname(__FILE__) + "/../../../config/starling/#{env}.yml"
  FileUtils.cp File.dirname(__FILE__) + '/config/starling.yml.tpl', starling_config unless File.exist?(starling_config)
end