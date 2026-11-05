class Post < ApplicationRecord
  belongs_to :user
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  validates :title, presence: true
  validates :content, presence: true
  enum :status, { unresolved: 0, resolved: 1 }
  enum :category, { ruby: 0, rails: 1, html: 2, css: 3, javascript: 4, git: 5, docker: 6, other: 7 }
  attr_accessor :tag_names
  after_save :save_tags, if: -> { !tag_names.nil? }

  def save_tags
    names = tag_names.to_s.split(",").map(&:strip).reject(&:blank?).uniq

    tags = names.map do |name|
      Tag.find_or_create_by!(name: name)
    end
    self.tags = tags
  end
end
