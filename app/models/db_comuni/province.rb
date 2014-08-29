class Province < ActiveRecord::Base
  include ConnectToDbComuni

  belongs_to :region
  has_many :municipalities

  validates :name, presence: true

  def name_with_abbreviation
    self.name + " (" + self.abbreviation + ")"
  end

end

# class Province < DBComuni

#   belongs_to :region

#   def municipalities 
#     has_many(:municipalities)
#   end

#   %w(name id abbreviation population density surface 
#     president email website created_at updated_at).each do |meth|
#     define_method(meth) { 
#       self.attributes[meth.to_sym]
#     }
#   end

#   def region_id
#     if self.prefix_options[:region_id]
#       return self.prefix_options[:region_id]
#     else
#       return self.attributes[:region_id]
#     end
#   end

#   def capital
#     self.region.capital
#   end

#   def symbol
#     has_one_symbol
#   end
  
#   def self.search(*args)
    
#     case args.size
  
#       when 1

#         if !args[0].nil?
#           result = Province.post(:search, headers = {:name => args[0]}).body
#           return Province.new(JSON.parse(result)) if result != "null"
#           return nil
#         else
#           puts "Usage: Province.search(name)"
#         end
        
#       else
#         puts "Usage: Province.search(name)"
#     end

#   end

# end