class CreateSolutions < ActiveRecord::Migration[8.1]
  def change
    create_table :solutions do |t|
      t.references :post, null: false, foreign_key: true
      t.text :solution, null: false
      t.string :url

      t.timestamps
    end
  end
end
