require 'byebug'
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # attributes = {}
    names.each do |name|
      # attributes[name] = nil
      ivar = "@#{name.to_s}"
      define_method "#{name.to_s}=" do |arg|
        # attributes[name] = arg
        instance_variable_set(ivar, attributes[name])
      end
      define_method name do
        instance_variable_get(ivar)
      end
    end
  end
end
