class AddUserToSolutions < ActiveRecord::Migration[8.1]
  def up
    add_reference :solutions, :user, null: true, foreign_key: true
    execute <<~SQL
     UPDATE solutions
     SET user_id = posts.user_id
     FROM posts
     WHERE solutions.post_id = posts.id
    SQL

    change_column_null :solutions, :user_id, false
  end

  def down
    remove_reference :solutions, :user, foreign_key: true
  end
end
