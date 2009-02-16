ENV["RAILS_ENV"] = "test"

require 'test/unit'
require 'rubygems'
require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Schema.define :version => 0 do
  create_table :users, :force => true do |t|
    t.column :email, :string
    t.column :url, :string
  end
end

class Mixin < ActiveRecord::Base
  def self.table_name() "users" end
end

class User < Mixin
  
end

class UserEmail < Mixin
  validates_email :email
end

class UserUrl < Mixin
  validates_url :url
end
