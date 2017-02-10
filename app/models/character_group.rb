class CharacterGroup < ActiveRecord::Base
  has_many :characters
  has_many :templates
  belongs_to :user
  validates_presence_of :name, :user

  attr_accessible :name
end
