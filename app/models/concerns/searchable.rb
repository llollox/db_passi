module Searchable
  extend ActiveSupport::Concern

  included do
    # has_many :taggings, as: :taggable
    # has_many :tags, through: :taggings

    # class_attribute :tag_limit
    before_save :update_name_encoded

    private 

    def update_name_encoded
      self.name_encoded = encode(self.name)
    end
  end

  # def tags_string
  #   tags.map(&:name).join(', ')
  # end

  # def tags_string=(tag_string)
  #   tag_names = tag_string.to_s.split(', ')

  #   tag_names.each do |tag_name|
  #     tags.build(name: tag_name)
  #   end
  # end

  # methods defined here are going to extend the class, not the instance of it
  module ClassMethods

    def search (*args)
      case args.size
        when 1
          return self.where(:name_encoded => encode(args[0])) if args[0].is_a?(String)
        when 2
          return self.where("name_encoded = ? AND region_id = ?", encode(args[0]), args[1]) if args[0].is_a?(String) and args[1].is_a?(Integer)
      end
      puts "Usage: #{self.class.name}.search(<name>) or #{self.class.name}.search(<name>,<region_id>)"
      return nil
    end

  end

end

def encode name
  name = name.downcase
  name = name.split("/").first if name.match(/\//)
  name = name.split("\\").first if name.match(/\\/)
  name = name.split(" - ").first if name.match(/ - /)
  name = name.gsub(/\s(e|del|dello|di|delle|dell|de|d|da|dal|della|dei|du|san|sant)\s/, '')
  name = name.gsub(/(d|dell|dall|sant)'\s*/,'')
  return name.gsub(/[^0-9A-Za-z]/, '')
end
