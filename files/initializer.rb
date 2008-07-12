
##
# Load starling setting and connect application to starling.
#

STARLING_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")['starling']
STARLING = Starling.new("#{STARLING_CONFIG['host']}:#{STARLING_CONFIG['port']}")