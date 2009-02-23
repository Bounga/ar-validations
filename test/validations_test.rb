require File.dirname(__FILE__) + '/test_helper'

class ValidationsTest < Test::Unit::TestCase
  def teardown
    User.delete_all
  end
  
  def test_without_url
    user = UserUrl.create
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
  
  def test_bad_url_with_custom_message
    user = UserUrlCustom.create :url => 'http://rorvalidations.com/'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    assert_equal("must be valid!", user.errors['url'].to_s)
  end
  
  def test_bad_url_with_allow_blank
    user = UserUrlAllowBlank.create :url => 'http://rorvalidations.com/'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_good_url_with_allow_blank
    user = UserUrlAllowBlank.create :url => 'http://www.google.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_good_url_without_http_with_allow_blank
    user = UserUrlAllowBlank.create :url => 'www.google.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    assert user.url, "http://www.google.com"
  end
  
  def test_without_url_with_allow_blank
    user = UserUrlAllowBlank.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_multiple_urls
    user = UserMultipleUrl.create :url => 'http://www.google.com', :url2 => 'http://www.yahoo.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserMultipleUrl.create :url => 'http://rorvalidations.com/', :url2 => 'http://www.yahoo.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserMultipleUrl.create :url => 'http://www.google.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_multiple_urls_with_allow_blank
    user = UserMultipleUrlAllowBlank.create :url => 'http://www.google.com', :url2 => 'http://www.yahoo.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserMultipleUrlAllowBlank.create :url => 'http://rorvalidations.com/', :url2 => 'http://www.yahoo.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserMultipleUrlAllowBlank.create :url => 'http://www.google.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserMultipleUrlAllowBlank.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_without_url_with_allow_nil
    user = UserUrlAllowNil.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserUrlAllowNil.create(:url => '')
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserMultipleUrlAllowNil.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserMultipleUrlAllowNil.create(:url => '')
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_without_url_on_update
    user = UserUrlUpdate.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.errors.inspect
    
    user.update_attribute(:email, 'test@example.com')
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserUrlUpdate.first
    user.update_attribute(:url, 'http://www.google.com')
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_without_email
    user = UserEmail.create
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_without_email_on_update
    user = UserEmailUpdate.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.errors.inspect
    
    user.update_attribute(:url, 'http://www.google.com')
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserEmailUpdate.first
    user.update_attribute(:email, 'test@example.com')
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
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
  
  def test_email_uniqueness
    user = UserEmailUniq.create :email => 'test@example.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user2 = UserEmailUniq.create :email => 'test@example.com'
    assert_not_nil user2.errors, user2.errors.inspect
    assert !user2.valid?, user2.inspect
    
    assert_equal(1, User.count)
    
    2.times do
      user = UserEmail.create :email => 'test@example.com'
      assert user.errors.empty?, user.errors.inspect
      assert user.valid?, user.inspect
    end
    
    assert_equal(3, User.count)
  end
  
  def test_bad_email_with_custom_message
    user = UserEmailCustom.create :email => 'test AT example.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    assert_equal("must be valid!", user.errors['email'].to_s)
  end
  
  def test_multiple_emails
    user = UserMultipleEmail.create :email => 'test@example.com', :email2 => 'test2@example.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserMultipleEmail.create :email => 'test AT example.com', :email2 => 'test3@example.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserMultipleEmail.create :email2 => 'test4@example.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_multiple_emails_with_allow_blank
    user = UserMultipleEmailAllowBlank.create :email => 'test@example.com', :email2 => 'test2@example.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserMultipleEmailAllowBlank.create :email => 'test AT example.com', :email2 => 'test3@example.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
    
    user = UserMultipleEmailAllowBlank.create :email2 => 'test4@example.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_without_email_with_allow_blank
    user = UserEmailAllowBlank.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_without_email_with_allow_nil
    user = UserEmailAllowNil.create
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
    
    user = UserEmailAllowNil.create(:email => '')
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
  
  def test_good_email_with_allow_blank
    user = UserEmailAllowBlank.create :email => 'test@example.com'
    assert user.errors.empty?, user.errors.inspect
    assert user.valid?, user.inspect
  end
  
  def test_bad_email_with_allow_blank
    user = UserEmailAllowBlank.create :email => 'test AT example.com'
    assert_not_nil user.errors, user.errors.inspect
    assert !user.valid?, user.inspect
  end
end
