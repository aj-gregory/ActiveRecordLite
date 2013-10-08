require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class_name
    @assoc_name.to_s.camelize
  end

  def other_class
    @assoc_name.capitalize.to_s.constantize
  end

  def other_table
    if assoc_name == :human
      return "humans"
    end
    @assoc_name.to_s
  end
end

class BelongsToAssocParams < AssocParams
  attr_accessor :primary_key, :foreign_key, :assoc_name

  def initialize(name, *params)
    @assoc_name = name  
    if ! params[0].empty? 
      @primary_key = params[0][:primary_key]
      @foreign_key = params[0][:foreign_key]
    else
      @primary_key = "id"
      @foreign_key = "#{name}_id"
    end
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params(type, name, *params)
    if type == 'belong'
      BelongsToAssocParams.new(name, *params)
    else
      HasManyAssocParams.new()
    end
  end

  def belongs_to(name, params = {})
    define_method(name) do
      assoc = self.class.assoc_params('belong', name, params)
      param_to_find = assoc.foreign_key
      hash_array = DBConnection.execute(<<-SQL)
        SELECT *
        FROM #{assoc.other_table}
        WHERE #{assoc.other_table}.#{assoc.primary_key} = #{self.send(param_to_find)}
        LIMIT 1
      SQL

      assoc.other_class.parse_all(hash_array).first
    end
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end


# assoc = BelongsToAssocParams.new('human')
# p assoc.primary_key
# p assoc.foreign_key
# p assoc.other_class_name