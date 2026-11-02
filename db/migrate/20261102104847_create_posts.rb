class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.date :date
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
