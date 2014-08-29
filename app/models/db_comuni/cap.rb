class Cap < ActiveRecord::Base
  include ConnectToDbComuni
  belongs_to :municipality
  
end

# class Cap < DBComuni

#   belongs_to :municipality

#   %w(number id municipality_id).each do |meth|
#     define_method(meth) { 
#       self.attributes[meth.to_sym]
#     }
#   end

#   def self.search(*args)
    
#     case args.size
#       when 1

#         if !args[0].nil?
#           result = Cap.post(:search, headers = {:number => args[0]}).body

#           if result != "null"
#             hash = JSON.parse(result)
#             if hash.to_s[0] == "[" # is array -> more than one
#               list = []
#               hash.each do |f|
#                 list << Cap.new(f)
#               end
#               return list
#             else # is a single element
#               return Cap.new(hash)
#             end
#           else
#             return nil
#           end

#         else
#           puts "Usage: Cap.search(number)"
#         end
        
#       else
#         puts "Usage: Cap.search(number)"
#     end
#   end

# end