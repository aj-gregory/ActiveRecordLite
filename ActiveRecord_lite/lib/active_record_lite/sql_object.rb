require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject

  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    object_array = []

    hash_array = DBConnection.execute(<<-SQL)
      SElECT *
      FROM "#{self.table_name}"
    SQL

    self.parse_all(hash_array)
  end

  def self.find(id)
    hash_array = DBConnection.execute(<<-SQL, id)
      SElECT *
      FROM "#{self.table_name}"
      WHERE ? = id 
    SQL

    self.new(hash_array[0])
  end

  def create
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO [#{self.class.table_name}] (#{self.class.attributes.join(',')})
      VALUES (#{(['?'] * 3).join(',')})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    DBConnection.execute(<<-SQL, *attribute_values[1..-1], attribute_values[0])
      UPDATE [#{self.class.table_name}]
      SET #{self.class.attributes[1..-1].map { |attr_name| "#{attr_name} = ?"}.join(', ')}
      WHERE ? = id
    SQL
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


cats_db_file_name =
  File.expand_path(File.join(File.dirname(__FILE__), "cats.db"))
DBConnection.open(cats_db_file_name)

class Cat < SQLObject
  set_table_name("cats")
  my_attr_accessible(:id, :name, :owner_id)

  belongs_to :human, :class_name => "Human", :primary_key => :id, :foreign_key => :owner_id
  has_one_through :house, :human, :house
end

class Human < SQLObject
  set_table_name("humans")
  my_attr_accessible(:id, :fname, :lname, :house_id)

  has_many :cats, :foreign_key => :owner_id
  belongs_to :house
end

class House < SQLObject
  set_table_name("houses")
  my_attr_accessible(:id, :address, :house_id)
end

cat = Cat.find(1)
p cat
p cat.human

human = Human.find(1)
p human.cats
p human.house