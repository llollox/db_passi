class DBComuniPicture < ActiveResource::Base

  self.site = "http://www2.westroadbike.it:3001/"
  self.element_name = "pictures"

  %w(id photo photo_url picturable_id picturable_type).each do |meth|
    define_method(meth) { 
      self.attributes[meth.to_sym]
    }
  end

end