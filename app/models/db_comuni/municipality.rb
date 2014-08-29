class Municipality < ActiveRecord::Base
  include ConnectToDbComuni
  include Searchable
  

  belongs_to :province
  belongs_to :region
  has_many :caps
  has_many :fractions

  
end

# class Municipality < DBComuni

#   belongs_to :province
#   belongs_to :region

#   %w(name id province_id region_id population density surface istat_code president 
#     cadastral_code telephone_prefix email website created_at 
#     updated_at latitude longitude).each do |meth|
#     define_method(meth) { 
#       self.attributes[meth.to_sym]
#     }
#   end

#   def caps
#     has_many(:caps)
#   end

#   def fractions
#     has_many(:fractions)
#   end

#   def capital
#     self.region.capital
#   end

#   def symbol
#     has_one_symbol
#   end

#   def self.contains(name)
#     parse_json(Municipality.post(:contains, headers = {:name => name}).body)
#   end

#   def self.search(*args)
    
#     case args.size

#       when 1

#         if !args[0].nil?

#           result = Municipality.post(:search, headers = {:name => args[0]}).body

#           if result != "null"
#             hash = JSON.parse(result)
#             if hash.to_s[0] == "[" # is array -> more than one
#               list = []
#               hash.each do |m|
#                 list << Municipality.new(m)
#               end
#               return list
#             else # is a single element
#               return Municipality.new(hash)
#             end
#           end

#         else
#           puts "Usage: search(region_id, name) region_id is optional!"
#         end
      
#       when 2
#         region_id = nil
#         name = nil

#         if !args[0].nil? && !args[1].nil?
#           if args[0].to_i == 0 # args[0] is a String
#             name = args[0]
#             region_id = args[1]
#           else
#             name = args[1]
#             region_id = args[0]
#           end

#           result = Municipality.post(:search, 
#             headers = {:name => name, :region_id => region_id}).body

#           return Municipality.new(JSON.parse(result)) if result != "null"

#         else
#           puts "Usage: search(region_id, name) region_id is optional!"
#         end
        
#       else
#         puts "Usage: search(region_id, name) region_id is optional!"
#     end

#   end

#   def self.parse_json result
#     if result != "null"
#       hash = JSON.parse(result)
#       if hash.to_s[0] == "[" # is array -> more than one
#         list = []
#         hash.each do |m|
#           list << Municipality.new(m)
#         end
#         return list
#       else # is a single element
#         return Municipality.new(hash)
#       end
#     end
#   end

# end