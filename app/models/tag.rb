class Tag < ActiveRecord::Base
  belongs_to :user
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags
  has_many :character_tags, dependent: :destroy
  has_many :characters, through: :character_tags

  validates_presence_of :user, :name
  validates :name, uniqueness: { scope: :type }

  attr_accessible :user, :user_id, :name, :type

  def editable_by?(user)
    user.try(:admin?)
  end

  def as_json(*args, **kwargs)
    {id: self.id, text: self.name}
  end

  def merge_with(other_tag)
    transaction do
      PostTag.where(tag_id: other_tag.id).where(post_id: post_tags.pluck('distinct post_id')).delete_all
      PostTag.where(tag_id: other_tag.id).update_all(tag_id: self.id)
      other_tag.destroy
    end
  end
end
