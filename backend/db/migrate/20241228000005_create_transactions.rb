class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :donation,              null: false, foreign_key: true
      t.string :stripe_payment_intent_id,  null: false
      t.decimal :amount,                   null: false, precision: 10, scale: 2
      t.integer :status,                   null: false, default: 0

      t.timestamps null: false
    end

    add_index :transactions, :stripe_payment_intent_id, unique: true
    add_index :transactions, :status
    add_index :transactions, :created_at
  end
end
