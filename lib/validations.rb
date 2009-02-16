require 'open-uri'

module Bounga
  module ActiveRecord
    module Validations
        RE_EMAIL_NAME   = '[\w\.%\+\-]+'                          # what you actually see in practice
        #RE_EMAIL_NAME   = '0-9A-Z!#\$%\&\'\*\+_/=\?^\-`\{|\}~\.' # technically allowed by RFC-2822
        RE_DOMAIN_HEAD  = '(?:[A-Z0-9\-]+\.)+'
        RE_DOMAIN_TLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
        RE_EMAIL_OK     = /\A#{RE_EMAIL_NAME}@#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}\z/i
        MSG_EMAIL_BAD   = "should look like an email address."
        MSG_URL_BAD     = "should be a valid url."

        def self.included(base)
          base.extend Validations::ClassMethods
        end

        module ClassMethods
          def validates_email(*fields)
            validates_each fields do |record, attr, value|
              validates_presence_of   attr
              validates_length_of     attr, :within => 6..100 #r@a.wk
              validates_uniqueness_of attr, :case_sensitive => false
              validates_format_of     attr, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
            end
          end
          
          def validates_url(*fields)
            validates_each fields do |record, attr, value|
              validates_presence_of   attr
              validates_length_of     attr, :minimum => 1, :too_short => MSG_URL_BAD
              record.send(attr.to_s + "=", "http://#{value}") unless value =~ /^(http|https|ftp)/i
              
              open(record.send(attr)) rescue record.errors.add(attr, MSG_URL_BAD) 
            end
          end
        end
    end
  end
end