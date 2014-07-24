class Region < ActiveResource::Base

  self.site = "http://0.0.0.0:3001"

  %w(name id symbol capital_id abbreviation president population 
    density surface email website created_at updated_at).each do |meth|
    define_method(meth) { 
      self.attributes[meth.to_sym]
    }
  end

  def provinces
    Province.find(:all, params: {region_id: self.id})
  end

  def symbol
    DBComuniPicture.find(:all, params: {picturable_id: self.id, picturable_type: "Region"}).first
  end

  def capital
    if self.capital_id
      Municipality.find(self.capital_id)
    end
  end

  def self.search(*args)
    
    case args.size
  
      when 1

        if !args[0].nil?
          result = Region.post(:search, headers = {:name => args[0]}).body
          return Region.new(JSON.parse(result)) if result != "null"
          return nil
        else
          puts "Usage: Region.search(name)"
        end
        
      else
        puts "Usage: Region.search(name)"
    end

  end

end