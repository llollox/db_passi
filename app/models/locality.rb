class Locality < ActiveRecord::Base
  attr_accessible :pass_id #, :fraction_id, :municipality_id
  belongs_to :pass
  belongs_to :localitiable, polymorphic: true
end
