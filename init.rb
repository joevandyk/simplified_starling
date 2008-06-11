require 'starling'
require 'simplified_starling'
require 'model_extensions'

ActiveRecord::Base.send(:include, ModelExtensions)

##
# TODO: Read config from a yaml file

##
# Raise an error if starling is not available

STARLING = Starling.new('127.0.0.1:22122')