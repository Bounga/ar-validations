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
        # * +:allow_nil+ - If set to +true+, skips this validation if the attribute is nil (default: +false+)
        # * +:on+ - Specifies when this validation is active (default is +:save+, other options +:create+, +:update+)
        # * +:with+ - The regular expression used to validate the email format with (default: RFC-2822 compliant)
        # * +:uniq+ - If set to +true+, ensure uniqueness of the attribute (default: +false+)
        # * +:message+ - A custom error message (default: +"should look like an email address."+)
        def validates_email(*fields)
          options = { :message => MSG_EMAIL_BAD, :on => :save, :with => RE_EMAIL_OK, :allow_blank => false, :allow_nil => false }
          options.update(fields.extract_options!)
          
          validates_each(fields, options) do |record, attr, value|
            validates_presence_of(attr) unless options[:allow_nil] or options[:allow_blank]
            
            with_options(:allow_blank => options[:allow_blank], :allow_nil => options[:allow_nil]) do |el|
              el.validates_length_of     attr, :within => 6..100
              el.validates_uniqueness_of attr, :case_sensitive => false if options[:uniq]
              el.validates_format_of     attr, :with => options[:with], :message => options[:message]
            end
          end
        end

        # Configuration options are:
        #
        # * +:allow_blank+ - If set to +true+, skips this validation if the attribute is blank (default: +false+)
        # * +:allow_nil+ - If set to +true+, skips this validation if the attribute is nil (default: +false+)
        # * +:on+ - Specifies when this validation is active (default is +:save+, other options +:create+, +:update+)
        # * +:with+ - The regular expression used to validate the format with (note: must be supplied!)
        # * +:if+ - Specifies a method, proc or string to call to determine if the validation should occur (e.g.
        # +:if => :allow_validation+, or +:if => Proc.new { |user| user.signup_step > 2 }+). The method, proc or 
        # string should return or evaluate to a true or false value.
        # * +:unless+ - Specifies a method, proc or string to call to determine if the validation should not occur
        # (e.g. +:unless => :skip_validation+, or +:unless => Proc.new { |user| user.signup_step <= 2 }+). The method,
        # proc or string should return or evaluate to a true or false value.
        # * +:message+ - A custom error message (default: +"should be a valid url."+)
        def validates_url(*fields)
          options = { :message => MSG_URL_BAD, :on => :save, :with => nil, :allow_blank => false, :allow_nil => false }
          options.update(fields.extract_options!)

          validates_each(fields, options) do |record, attr, value|
            validates_presence_of(attr) unless options[:allow_nil] or options[:allow_blank]

            record.send(attr.to_s + "=", "http://#{value}") unless value =~ /^(http|https|ftp)/i 
            open(record.send(attr)) rescue record.errors.add(attr, options[:message]) unless value.blank?
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Bounga::ActiveRecord::Validations)