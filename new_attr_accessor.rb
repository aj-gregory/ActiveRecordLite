class Object
  def new_attr_accessor(*args)
  	args.each do |arg|
  	  p arg
      self.send(:define_method, arg) { instance_variable_get("@#{arg.to_s}") }
      self.send(:define_method, "#{arg.to_s}=".to_sym) { |new_name| instance_variable_set("@#{arg}", new_name) }
  	end
  end
end

class Cat
	new_attr_accessor :name, :color
end
