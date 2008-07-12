development:
  host: 127.0.0.1
  port: 22122
  pid_file: /tmp/starling_app_development.pid
  queue_path: /tmp
  timeout: 0
  syslog_channel: starling-tampopo
  log_level: DEBUG
  daemonize: true
  queue: app_development

test:
  host: 127.0.0.1
  port: 22122
  pid_file: /tmp/starling_app_test.pid
  queue_path: /tmp
  timeout: 0
  syslog_channel: starling-tampopo
  log_level: DEBUG
  daemonize: true
  queue: app_test

production:
  host: 127.0.0.1
  port: 22122
  pid_file: /tmp/starling_app_production.pid
  queue_path: /tmp
  timeout: 0
  syslog_channel: starling-tampopo
  log_level: DEBUG
  daemonize: true
  queue: app_production
