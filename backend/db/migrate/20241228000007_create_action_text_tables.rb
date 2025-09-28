class CreateActionTextTables < ActiveRecord::Migration[8.0]
  def change
    # Use Action Text's built-in generator
    # rails generate action_text:install
    
    create_table :action_text_rich_texts, if_not_exists: true do |t|
      t.string     :name, null: false
      t.text       :body
      t.references :record, null: false, polymorphic: true, index: false

      t.timestamps

      t.index [ :record_type, :record_id, :name ],
              name: "index_action_text_rich_texts_uniqueness",
              unique: true
    end
  end
end
