class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.references :Document, null: false, foreign_key: true
      t.text :content
      t.integer :number
      t.blob :embedding

      t.timestamps
    end
  end
end
