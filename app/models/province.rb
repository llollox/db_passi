class Province < ActiveResource::Base

  include ShallowNestedRoutes
  set_shallow_nested_route_parent :region

  self.site = "http://0.0.0.0:3001"

  def self.all
    provinces = []
    Region.all.each do |r| 
      r.provinces.each do |p| 
        provinces = provinces << p
      end 
    end
    
    return provinces
  end

  %w(name id abbreviation population density surface 
    president email website created_at updated_at).each do |meth|
    define_method(meth) { 
      self.attributes[meth.to_sym]
    }
  end

  def region_id
    if self.prefix_options[:region_id]
      return self.prefix_options[:region_id]
    else
      return self.attributes[:region_id]
    end
  end

  def region
    Region.find(self.region_id)
  end

  def capital
    self.region.capital
  end

  def symbol
    DBComuniPicture.find(:all, params: {picturable_id: self.id, picturable_type: "Province"}).first
  end

  def municipalities
    Municipality.find(:all, params: { province_id: self.id})
  end

  def self.search(*args)
    
    case args.size
  
      when 1

        if !args[0].nil?
          result = Province.post(:search, headers = {:name => args[0]}).body
          return Province.new(JSON.parse(result)) if result != "null"
          return nil
        else
          puts "Usage: Province.search(name)"
        end
        
      else
        puts "Usage: Province.search(name)"
    end

  end

end