class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :file_name
      t.text :shem

      t.timestamps
    end
    add_index :documents, :file_name
  end
end
