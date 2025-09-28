class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :title,           null: false
      t.text :description,       null: false
      t.decimal :goal_amount,    null: false, precision: 10, scale: 2
      t.datetime :deadline,      null: false
      t.integer :status,         null: false, default: 0
      t.references :creator,     null: false, foreign_key: { to_table: :users }

      t.timestamps null: false
    end

    add_index :campaigns, :status
    add_index :campaigns, :deadline
    add_index :campaigns, :created_at
  end
end
