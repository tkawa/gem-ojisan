class CreateProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.string :slug, null: false

      t.timestamps null: false
    end
    add_index :projects, :slug, unique: true
  end
end
