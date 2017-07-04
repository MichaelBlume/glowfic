class GalleriesIcon < ActiveRecord::Base
  belongs_to :icon
  belongs_to :gallery
  accepts_nested_attributes_for :icon, allow_destroy: true

  after_create :set_has_gallery
  after_destroy :unset_has_gallery
  validates :gallery_id, uniqueness: { scope: :icon_id }

  def unset_has_gallery
    return if icon.galleries.present?
    icon.update_attributes(has_gallery: false)
  end

  def set_has_gallery
    return if icon.has_gallery?
    icon.update_attributes(has_gallery: true)
  end
end
