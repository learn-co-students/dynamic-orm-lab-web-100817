require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require "pry"

class Student < InteractiveRecord
    def self.table_name
      self.to_s.downcase.pluralize
    end

    def self.column_names
      DB[:conn].results_as_hash = true
      table_info = DB[:conn].execute("pragma table_info('#{table_name}')")
      table_info.map{|column| column["name"]}
    end

    self.column_names.each{|col_name| attr_accessor col_name.to_sym}

    def initialize(options = {})
      options.each{|property, value| self.send("#{property}=", value)}
    end

    def table_name_for_insert
      self.class.table_name
    end

    def col_names_for_insert
      self.class.column_names.delete_if{|name| name == "id"}.join(", ")
    end

    def values_for_insert
      values = []
      self.class.column_names.each{|col| values << "'#{send(col)}'" unless send(col).nil?}
      values.join(", ")
    end

    def save
      sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"


      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() From '#{table_name_for_insert}'")[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = name"
        DB[:conn].execute(sql)
    end

    def self.find_by(attribute)
      # binding.pry

      sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = ?"
      DB[:conn].execute(sql,attribute[attribute.keys[0]])
    end
end
