require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    DBConnection.execute(<<-SQL)
      SElECT *
      FROM "#{self.table_name}"
    SQL
  end

  def self.find(id)
    DBConnection.execute(<<-SQL, id)
      SElECT *
      FROM "#{self.table_name}"
      WHERE ? = id 
    SQL
  end

  def create
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO [#{self.class.table_name}] (#{self.class.attributes.join(',')})
      VALUES (#{(['?'] * 3).join(',')})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # DBConnection.execute(<<-SQL, *values)
    #   UPDATE [#{self.table_name}]
    #   SET 
    # SQL
    # self.id = DBConnection.
    p "CALLED UPDATE"
  end

  def save
    if self.id.nil?
      self.create
    else
      self.update
    end
  end

  def attribute_values
    self.class.attributes.map { |attribute| self.send(attribute) }
  end
end

#--TESTS--#

cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open(cats_db_file_name)

class Cat < SQLObject
  set_table_name("cats")
  my_attr_accessible(:id, :name, :owner_id)
end

class Human < SQLObject
  set_table_name("humans")
  my_attr_accessible(:id, :fname, :lname, :house_id)
end

p Human.superclass
p Human.find(1)
p Cat.find(1)
p Cat.find(2)

p Human.all
p Cat.all
