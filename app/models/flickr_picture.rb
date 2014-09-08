class FlickrPicture < ActiveRecord::Base
  attr_accessible :photo_url, :picturable_id, :picturable_type
  belongs_to :picturable, polymorphic: true
end
