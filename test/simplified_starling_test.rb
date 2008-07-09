require 'test/unit'
require 'rubygems'
require 'active_record'
require 'starling'
require 'simplified_starling'
require 'simplified_starling/active_record'
require 'simplified_starling/daemonize'

# require  + "/fixtures/schema"

RAILS_ROOT = "/tmp"
RAILS_ENV = 'test'

@starling_config_file = File.dirname(__FILE__) + '/starling.yml'

STARLING_CONFIG = YAML.load_file(@starling_config_file)
host, port = STARLING_CONFIG['starling']['host'], STARLING_CONFIG['starling']['port']

STARLING = Starling.new("#{host}:#{port}")

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :posts do |t|
      t.string :title, :nil => false
      t.boolean :status, :default => false
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Post < ActiveRecord::Base

  def rebuild
    self.update_attributes :status => true
  end

  def self.publish_all
    update_all :status => true
  end

  def self.unpublish_all
    update_all :status => false
  end

end

class SimplifiedStarlingTest < Test::Unit::TestCase

  def setup
    setup_db
    Post.create(:title => "First Post")
  end

  def teardown
    teardown_db
  end

  def test_array_class_is_not_affected_by_method_overwrite
    a = [ "a", "b", "c" ]
    a.push("d", "e", "f")
    assert_equal a, ["a", "b", "c", "d", "e", "f"]
  end

  def test_should_push_a_class_method_on_post
    post = Post.find(:first)
    assert !post.status
    Post.push('publish_all')
    Simplified::Starling.process('your_application_name')
    post = Post.find(:first)
    assert post.status
    Post.push('unpublish_all')
    post = Post.find(:first)
    assert post.status
    Simplified::Starling.process('your_application_name')
    post = Post.find(:first)
    assert !post.status
  end

  def test_should_push_an_instance_method_on_post
    post = Post.find(:first)
    assert !post.status
    Post.find(:first).push('rebuild')
    Simplified::Starling.process('your_application_name')
    post = Post.find(:first)
    assert post.status
  end

end