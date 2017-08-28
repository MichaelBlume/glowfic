class Gallery < ActiveRecord::Base
  include Taggable
  belongs_to :user

  has_many :galleries_icons, dependent: :destroy
  accepts_nested_attributes_for :galleries_icons, allow_destroy: true
  has_many :icons, -> { order('LOWER(keyword)') }, through: :galleries_icons

  has_many :characters_galleries, inverse_of: :gallery
  has_many :characters, through: :characters_galleries

  has_many :gallery_tags, inverse_of: :gallery, dependent: :destroy
  has_many :gallery_groups, through: :gallery_tags, source: :gallery_group

  validates_presence_of :user, :name

  acts_as_tag :gallery_group

  scope :ordered, -> { order('characters_galleries.section_order ASC') }
  scope :with_icon_count, -> {
    joins('LEFT JOIN galleries_icons ON galleries.id = galleries_icons.gallery_id')
      .select("galleries.*, count(galleries_icons.id) as icon_count")
      .group("galleries.id")
  }

  def character_gallery_for(character)
    characters_galleries.where(character_id: character).first
  end
end
