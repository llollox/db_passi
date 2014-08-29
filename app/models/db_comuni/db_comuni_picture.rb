class DBComuni::DBComuniPicture < DBComuni
	
  %w(id photo_content_type photo_file_name 
  		photo_file_size photo_updated_at photo_url 
  		picturable_id picturable_type updated_at).each do |meth|
    define_method(meth) { 
      self.attributes[meth.to_sym]
    }
  end

end