require 'fileutils'

starling_config = File.dirname(__FILE__) + '/../../../config/starling.yml'
FileUtils.cp File.dirname(__FILE__) + '/config/starling.yml.tpl', starling_config unless File.exist?(starling_config)