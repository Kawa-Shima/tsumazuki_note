class Solution < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :solution, presence: true
end
