class CreateFlickrPictures < ActiveRecord::Migration
  def change
    create_table :flickr_pictures do |t|
      t.string :photo_url
      t.string :title
      t.belongs_to :picturable, polymorphic: true

      t.timestamps
    end
    add_index :flickr_pictures, [:picturable_id, :picturable_type]
  end
end
