class Municipality < ActiveResource::Base
  require 'json'
  include ShallowNestedRoutes
  set_shallow_nested_route_parent :province

  self.site = "http://www2.westroadbike.it:3001/"

  def self.all
    municipalities = []
    Province.all.each do |p| 
      p.municipalities.each do |m| 
        municipalities = municipalities << m
      end 
    end
    
    return municipalities
  end

  def self.search(*args)
    
    case args.size

      when 1

        if !args[0].nil?

          result = Municipality.post(:search, headers = {:name => args[0]}).body

          if result != "null"
            hash = JSON.parse(result)
            if hash.to_s[0] == "[" # is array -> more than one
              list = []
              hash.each do |m|
                list << Municipality.new(m)
              end
              return list
            else # is a single element
              return Municipality.new(hash)
            end
          end

        else
          puts "Usage: search(province_id, name) province_id is optional!"
        end
      
      when 2
        province_id = nil
        name = nil

        if !args[0].nil? && !args[1].nil?
          if args[0].to_i == 0 # args[0] is a String
            name = args[0]
            province_id = args[1]
          else
            name = args[1]
            province_id = args[0]
          end

          result = Municipality.post(:search, 
            headers = {:name => name, :province_id => province_id}).body

          return Municipality.new(JSON.parse(result)) if result != "null"

        else
          puts "Usage: search(province_id, name) province_id is optional!"
        end
        
      else
        puts "Usage: search(province_id, name) province_id is optional!"
    end

  end

  %w(name id population density surface istat_code president 
    cadastral_code telephone_prefix email website created_at 
    updated_at latitude longitude).each do |meth|
    define_method(meth) { 
      self.attributes[meth.to_sym]
    }
  end

  def province_id
    if self.prefix_options[:province_id]
      return self.prefix_options[:province_id]
    else
      return self.attributes[:province_id]
    end
  end

  def province
    result = Province.find(self.province_id)
    result = result.first if result.class.name.to_s == "Array"
    return result
  end

  def region
    self.province.region
  end

  def capital
    self.region.capital
  end

  def symbol
    symbol = DBComuniPicture.find(:all, params: {picturable_id: self.id, picturable_type: "Municipality"}).first
    return symbol.first if !symbol.nil?
  end

  def caps
    Cap.find(:all, params: { municipality_id: self.id})
  end

  def fractions
    Fraction.find(:all, params: { municipality_id: self.id})
  end

end