module ShallowNestedRoutes
	def self.included(base)
		base.extend(ClassMethods)
	end
 
	module ClassMethods
		# Pass in the name of the parent class
		def set_shallow_nested_route_parent(parent)
			parent = parent.to_s
			# Override these methods so they set the prefix path before a call and reset it afterward.
			# This is used for shallow nested routes because ActiveRecord does not handle these well.
			%w(all build create find_every).each do |method|
				define_singleton_method(method.to_sym) do |*args|
					old_prefix = self.prefix
					self.prefix = "/#{parent.pluralize}/:#{parent}_id/"
					begin
						super(*args) # Return the result from calling the parent method
					ensure
						# Make sure prefix is reset when done
						self.prefix = old_prefix
					end
				end
			end
		end
	end
end