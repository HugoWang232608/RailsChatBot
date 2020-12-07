class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.string :body
      t.boolean :from_bot
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
