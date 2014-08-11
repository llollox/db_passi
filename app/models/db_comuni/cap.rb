class Cap < ActiveResource::Base
  require 'json'
  include ShallowNestedRoutes
  set_shallow_nested_route_parent :municipality

  self.site = "http://www2.westroadbike.it:3001/"

  def self.search(*args)
    
    case args.size
      when 1

        if !args[0].nil?
          result = Cap.post(:search, headers = {:number => args[0]}).body

          if result != "null"
            hash = JSON.parse(result)
            if hash.to_s[0] == "[" # is array -> more than one
              list = []
              hash.each do |f|
                list << Cap.new(f)
              end
              return list
            else # is a single element
              return Cap.new(hash)
            end
          else
            return nil
          end

        else
          puts "Usage: Cap.search(number)"
        end
        
      else
        puts "Usage: Cap.search(number)"
    end
  end


  %w(number id).each do |meth|
    define_method(meth) { 
      self.attributes[meth.to_sym]
    }
  end

  def municipality_id
    if self.prefix_options[:municipality_id]
      return self.prefix_options[:municipality_id]
    else
      return self.attributes[:municipality_id]
    end
  end

  def municipality
    Municipality.find(self.municipality_id)
  end
end