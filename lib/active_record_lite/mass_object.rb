class MassObject
  def self.my_attr_accessible(*attributes)
  	attributes.each do |attribute|
  	  self.attributes << attribute
  	  self.send(:attr_accessor, attribute)
  	end
  end

  def self.attributes
  	@attributes ||= []
  end

  def self.parse_all(results)
  	object_array = []
  	results.each do |hash|
       object_array << self.new(hash)
    end

    object_array
  end

  def initialize(params = {})
    params.keys.each do |param|
      if self.class.attributes.include?(param.to_sym)
	    self.send("#{param}=", params[param])
	  else
	    raise "mass assignment to unregistered attribute #{param}"
	  end
    end
  end

end