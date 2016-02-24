class BoardView < ActiveRecord::Base
  belongs_to :board
  belongs_to :user

  validates_presence_of :user, :board
end