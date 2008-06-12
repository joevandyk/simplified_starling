require 'starling'
require 'simplified_starling'
require 'model_extensions'

ActiveRecord::Base.send(:include, ModelExtensions)

config = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
host, port = config['starling']['host'], config['starling']['port']

STARLING = Starling.new("#{host}:#{port}")