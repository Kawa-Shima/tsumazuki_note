class AddCategoryToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :category, :integer
  end
end
