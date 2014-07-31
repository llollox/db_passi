class Pass < ActiveRecord::Base
  attr_accessible :altitude, :latitude, :longitude, :name
  has_many :localities, :dependent => :delete_all

  geocoded_by :address
	after_validation :geocode

	def address
		address = self.name 
		if !self.localities.empty?
			loc = self.localities.first
			address = address + ", " + loc.municipality.province.name + ", " + loc.municipality.province.region.name if loc.class.name == "Fraction"
			address = address + ", " + loc.province.name + ", " + loc.province.region.name if loc.class.name == "Municipality"
		end
		return address + ", Italy"
	end
end
