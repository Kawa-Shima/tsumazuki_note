class Post < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :content, presence: true
  enum :status, { unresolved: 0, resolved: 1 }
end
