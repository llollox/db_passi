class Region < ActiveRecord::Base
  include ConnectToDbComuni
  include Searchable

  has_and_belongs_to_many :trips

  has_many :provinces
  has_many :municipalities
  has_many :fractions

  def capital
    Municipality.find self.capital_id
  end
  
end

# class Region < DBComuni

#   %w(name id symbol capital_id abbreviation president population 
#     density surface email website created_at updated_at).each do |meth|
#     define_method(meth) { 
#       self.attributes[meth.to_sym]
#     }
#   end

#   def provinces 
#     has_many(:provinces)
#   end

#   def symbol
#     has_one_symbol
#   end

#   def capital
#     Municipality.find(self.capital_id) if self.capital_id
#   end

#   def trips
#     l = RegionTrip.where(:region_id => self.id)
#     result = []
#     l.each do |t|
#       result = result << Trip.find(t.trip_id)
#     end
#     return result
#   end

#   def self.search(*args)
    
#     case args.size
  
#       when 1

#         if !args[0].nil?
#           result = Region.post(:search, headers = {:name => args[0]}).body
#           return Region.new(JSON.parse(result)) if result != "null"
#           return nil
#         else
#           puts "Usage: Region.search(name)"
#         end
        
#       else
#         puts "Usage: Region.search(name)"
#     end

#   end

# end