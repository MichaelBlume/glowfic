class IndexSection < ApplicationRecord
  include Orderable

  belongs_to :index, inverse_of: :index_sections
  has_many :index_posts, inverse_of: :index_section, dependent: :destroy
  has_many :posts, through: :index_posts

  validates_presence_of :name, :index

  private

  def ordered_attributes
    [:index_id]
  end
end