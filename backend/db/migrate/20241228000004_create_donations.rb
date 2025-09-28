class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations do |t|
      t.references :user,       null: false, foreign_key: true
      t.references :campaign,   null: false, foreign_key: true
      t.decimal :amount,        null: false, precision: 10, scale: 2
      t.boolean :anonymous,     null: false, default: false
      t.integer :status,        null: false, default: 0

      t.timestamps null: false
    end

    add_index :donations, :status
    add_index :donations, :created_at
    add_index :donations, [:campaign_id, :status]
    add_index :donations, [:user_id, :status]
    add_index :donations, :amount
  end
end
