class CreateOtps < ActiveRecord::Migration[8.0]
  def change
    create_table :otps do |t|
      t.string :phone_number, null: false
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.boolean :used, default: false
      t.timestamps
    end
    add_index :otps, :phone_number
    add_index :otps, :code
  end
end
