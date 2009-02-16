require File.join(File.dirname(__FILE__), 'lib', 'ar-validations')
::ActiveRecord::Base.send :include, ::Bounga::ActiveRecord::Validations