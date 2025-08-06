class CreateSleepRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :sleep_at, null: false
      t.datetime :wake_up_at

      t.timestamps
    end

    add_index :sleep_records, :sleep_at
    add_index :sleep_records, :wake_up_at

    add_index :sleep_records, [:user_id, :sleep_at]
  end
end
