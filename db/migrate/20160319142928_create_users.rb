class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :nickname
      t.string :image

      t.timestamps null: false
    end
    add_index :users, :name, unique: true
  end
end
