class Fraction < ActiveResource::Base

  include ShallowNestedRoutes
  set_shallow_nested_route_parent :municipality

  self.site = "http://0.0.0.0:3001"

  def self.all
    fractions = []
    Municipality.all.each do |m| 
      m.fractions.each do |f| 
        fractions = fractions << f
      end 
    end
    
    return fractions
  end

  %w(name id created_at updated_at).each do |meth|
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

  def self.search(*args)
    
    case args.size
  
      when 1

        if !args[0].nil?
          result = Fraction.post(:search, headers = {:name => args[0]}).body

          if result != "null"
            hash = JSON.parse(result)
            if hash.to_s[0] == "[" # is array -> more than one
              list = []
              hash.each do |f|
                list << Fraction.new(f)
              end
              return list
            else # is a single element
              return Fraction.new(hash)
            end
          else
            return nil
          end

        else
          puts "Usage: Fraction.search(name)"
        end
        
      else
        puts "Usage: Fraction.search(name)"
    end

  end

end