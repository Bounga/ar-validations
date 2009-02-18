ENV["RAILS_ENV"] = "test"
$KCODE = 'u'

require 'test/unit'
require 'rubygems'
require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Schema.define :version => 0 do
  create_table :users, :force => true do |t|
    t.column :email, :string
    t.column :email2, :string
    t.column :url, :string
    t.column :url2, :string
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

class UserEmailCustom < Mixin
  validates_email :email, :message => "must be valid!"
end

class UserEmailUniq < Mixin
  validates_email :email, :uniq => true
end

class UserEmailAllowBlank < Mixin
  validates_email :email, :allow_blank => true
end

class UserMultipleEmail < Mixin
  validates_email :email, :email2
end

class UserMultipleEmailAllowBlank < Mixin
  validates_email :email, :email2, :allow_blank => true
end

class UserUrl < Mixin
  validates_url :url
end

class UserUrlCustom < Mixin
  validates_url :url, :message => "must be valid!"
end

class UserUrlAllowBlank < Mixin
  validates_url :url, :allow_blank => true
end

class UserUrlAllowNil < Mixin
  validates_url :url, :allow_nil => true
end

class UserMultipleUrl < Mixin
  validates_url :url, :url2
end

class UserMultipleUrlAllowBlank < Mixin
  validates_url :url, :url2, :allow_blank => true
end

class UserMultipleUrlAllowNil < Mixin
  validates_url :url, :url2, :allow_nil => true
end
