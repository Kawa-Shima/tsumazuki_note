class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :username, :string
    execute <<~SQL
      UPDATE users
      SET username = 'ユーザー' || id
    SQL
    change_column_null :users, :username, false
  end

  def down
    remove_column :users, :username
  end
end
