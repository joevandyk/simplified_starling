STARLING_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/starling/#{RAILS_ENV}.yml")
host, port = STARLING_CONFIG['starling']['host'], STARLING_CONFIG['starling']['port']

STARLING = Starling.new("#{host}:#{port}")