class CreateEbooks < ActiveRecord::Migration[8.0]
  def change
    create_table :ebooks do |t|
      t.string :title
      t.string :author
      t.string :file_name
      t.integer :file_size
      t.string :file_type
      t.datetime :uploaded_at

      t.timestamps
    end
  end
end
