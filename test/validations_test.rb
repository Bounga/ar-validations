require File.dirname(__FILE__) + '/test_helper'

class ValidationsTest < Test::Unit::TestCase
  def setup_db
    ActiveRecord::Schema.define(:version => 1) do
      create_table :authors do |t|
        t.string :name, :title
      end
    end
  end

  def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
  
  def test_good_email
    user = UserEmail.create :email => 'test@example.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_bad_email
    user = UserEmail.create :email => 'test AT example.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_bad_url
    user = UserUrl.create :url => 'http://rorvalidations.com/'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_good_url
    user = UserUrl.create :url => 'http://www.google.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_good_url_without_http
    user = UserUrl.create :url => 'www.google.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    assert user.url, "http://www.google.com"
  end
end
