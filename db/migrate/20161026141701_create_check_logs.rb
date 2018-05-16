class CreateCheckLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :check_logs do |t|
      t.integer :remotty_entry_id
      t.integer :remotty_stats_entry_id
      t.integer :remotty_gems_entry_id

      t.timestamps null: false
    end
  end
end
