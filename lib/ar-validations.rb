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
        base.extend ClassMethods
      end

      # This ActiveRecord extension provides more validation schemes.
      # You can validate:
      # * **email**: It checks for presence, length, format and uniqueness. There is no guarantee that a validated email is real and deliverable.
      # * **URLs**: It checks for validity of the link by contacting it. If not protocol is not specified, it'll automatically add "http://" in front of the url.
      #
      # User example:
      #
      #   class User < ActiveRecord::Base
      #     validates_email :email
      #     validates_url :url
      #   end
      module ClassMethods
        # Configuration options are:
        #
        # * +:allow_blank+ - If set to +true+, skips this validation if the attribute is blank (default: +false+)
        # * +:uniq+ - If set to +true+, ensure uniqueness of the attribute (default: +false+)
        # * +:message+ - A custom error message (default: +"should look like an email address."+)
        def validates_email(*fields)
          options = fields.extract_options!

          validates_each fields do |record, attr, value|
            validates_presence_of(attr) unless options[:allow_blank]
            next if options[:allow_blank] and value.blank?
            
            validates_length_of     attr, :within => 6..100, :allow_blank => options[:allow_blank]
            validates_uniqueness_of attr, :case_sensitive => false, :allow_blank => options[:allow_blank] if options[:uniq]
            validates_format_of     attr, :with => RE_EMAIL_OK, :message => (options[:message] || MSG_EMAIL_BAD), :allow_blank => options[:allow_blank]
          end
        end

        # Configuration options are:
        #
        # * +:allow_blank+ - If set to +true+, skips this validation if the attribute is blank (default: +false+)
        # * +:message+ - A custom error message (default: +"should be a valid url."+)
        def validates_url(*fields)
          options = fields.extract_options!

          validates_each fields do |record, attr, value|
            validates_presence_of(attr) unless options[:allow_blank]
            next if options[:allow_blank] and value.blank?

            record.send(attr.to_s + "=", "http://#{value}") unless value =~ /^(http|https|ftp)/i
            open(record.send(attr)) rescue record.errors.add(attr, (options[:message] || MSG_URL_BAD))
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Bounga::ActiveRecord::Validations)