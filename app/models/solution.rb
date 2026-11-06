class Solution < ApplicationRecord
  belongs_to :post

  validates :solution, presence: true
end
