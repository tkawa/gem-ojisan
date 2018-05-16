class CreateProjectCheckLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :project_check_logs do |t|
      t.references :project, index: true, foreign_key: true
      t.references :check_log, index: true, foreign_key: true
      t.string :color, null: false
      t.integer :red_count, null: false
      t.integer :dependency_count, null: false

      t.timestamps null: false
    end
  end
end
