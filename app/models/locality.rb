class Locality < ActiveRecord::Base
  attr_accessible :pass_id, :fraction_id, :municipality_id
  belongs_to :pass
  belongs_to :municipality
  belongs_to :fraction

  def municipality	
  	Municipality.find(self.municipality_id) if !self.municipality_id.nil?
  end

  def fraction
  	Fraction.find(self.fraction_id) if !self.fraction_id.nil?
  end

end
