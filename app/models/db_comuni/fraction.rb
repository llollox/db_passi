class Fraction < ActiveRecord::Base
  include ConnectToDbComuni
  include Searchable

  belongs_to :municipality
  belongs_to :region

  geocoded_by :address

  def address
    address = self.name
    address += ", " + self.municipality.name
    address += ", " + self.municipality.province.name
    address += ", " + self.municipality.province.abbreviation
    address += ", " + self.municipality.caps.first.number.to_s if !self.municipality.caps.blank?
    address += ", " + self.region.name
    address += ", Italy"
    return address
  end
  
end

# class Fraction < DBComuni

#   belongs_to :municipality
#   belongs_to :region

#   %w(name id municipality_id created_at updated_at).each do |meth|
#     define_method(meth) { 
#       self.attributes[meth.to_sym]
#     }
#   end

#   def self.search(*args)
    
#     case args.size
  
#       when 1

#         if !args[0].nil?
#           result = Fraction.post(:search, headers = {:name => args[0]}).body

#           if result != "null"
#             hash = JSON.parse(result)
#             if hash.to_s[0] == "[" # is array -> more than one
#               list = []
#               hash.each do |f|
#                 list << Fraction.new(f)
#               end
#               return list
#             else # is a single element
#               return Fraction.new(hash)
#             end
#           else
#             return nil
#           end

#         else
#           puts "Usage: Fraction.search(region_id, name) region_id is optional!"
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

#           result = Fraction.post(:search, 
#             headers = {:name => name, :region_id => region_id}).body

#           if result != "null"
#             hash = JSON.parse(result)
#             if hash.to_s[0] == "[" # is array -> more than one
#               list = []
#               hash.each do |m|
#                 list << Fraction.new(m)
#               end
#               return list
#             else # is a single element
#               return Fraction.new(hash)
#             end
#           end

#         else
#           puts "Usage: Fraction.search(region_id, name) region_id is optional!"
#         end

        
#       else
#         puts "Usage: Fraction.search(region_id, name) region_id is optional!"
#     end

#   end

# end