require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class_name
    if @type == 'belongs_to'
      @assoc_name.to_s.camelize
    else
      @assoc_name.to_s.singularize.camelize
    end
  end

  def other_class
    other_class_name.constantize
  end

  def other_table
    if assoc_name == :human
      return "humans"
    end

    if @type == 'belongs_to'
      @assoc_name.to_s.pluralize
    else
      @assoc_name.to_s
    end
  end
end

class BelongsToAssocParams < AssocParams
  attr_accessor :primary_key, :foreign_key, :assoc_name

  def initialize(name, params)
    @assoc_name = name 
    @typ = type 
    if params[:primary_key]
      @primary_key = params[:primary_key]
    else
       @primary_key = "id"
    end
    if params[:foreign_key]
      @foreign_key = params[:foreign_key]
    else
      @foreign_key = "#{name}_id"
    end
  end

  def type
    @type = 'belongs_to'
  end
end

class HasManyAssocParams < AssocParams
  attr_accessor :primary_key, :foreign_key, :assoc_name

  def initialize(name, params, self_class)
    @assoc_name = name 
    @type = type 
    p params
    if params[:primary_key]
      @primary_key = params[:primary_key]
    else
       @primary_key = "id"
    end
    if params[:foreign_key]
      @foreign_key = params[:foreign_key]
    else
      @foreign_key = "#{self_class.snake_case}_id"
    end
  end

  def type
    @type = 'has_many'
  end
end

module Associatable
  def assoc_params(type, name, *params)
    if type == 'belong'
      BelongsToAssocParams.new(name, *params)
    else
      HasManyAssocParams.new(name, *params, self.class)
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
    define_method(name) do
      assoc = self.class.assoc_params('has_many', name, params)
      param_to_find = assoc.primary_key
      hash_array = DBConnection.execute(<<-SQL)
        SELECT *
        FROM #{assoc.other_table}
        WHERE #{assoc.other_table}.#{assoc.foreign_key} = #{self.send(param_to_find)}
      SQL

      assoc.other_class.parse_all(hash_array)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end

end


# assoc = BelongsToAssocParams.new('human')
# p assoc.primary_key
# p assoc.foreign_key
# p assoc.other_class_name