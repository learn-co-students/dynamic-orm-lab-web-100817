require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require 'pry'

class Student < InteractiveRecord
  self.column_names.each do |column_name|
    # binding.pry
    # if column_name.class == String
      attr_accessor column_name.to_sym
     #end
  end

  def initialize(options={})
    options.each do |property,value|
        # binding.pry
      self.send("#{property}=",value)
    end
  end


end
