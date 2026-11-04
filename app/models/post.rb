class Post < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :content, presence: true
  enum :status, { unresolved: 0, resolved: 1 }
  enum :category, { ruby: 0, rails: 1, html: 2, css: 3, javascript: 4, git: 5, docker: 6, other: 7 }
end
