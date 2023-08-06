class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.text :q
      t.text :a
      t.integer :ask_count

      t.timestamps
    end
  end
end
