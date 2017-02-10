class Template < ActiveRecord::Base
  belongs_to :user, inverse_of: :templates
  has_many :characters

  validates_presence_of :name
  attr_accessible :user, :user_id, :name, :description

  before_destroy :clear_character_templates

  def ordered_characters
    characters.order('LOWER(name)')
  end

  private

  def clear_character_templates
    characters.update_all(template_id: nil)
  end
end
