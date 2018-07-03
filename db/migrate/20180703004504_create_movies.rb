class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string  :title
      t.string :genre
      t.string :director
      t.string :actor
      t.string :image_path
      
      t.references :user # t.integer :user_id 랑 같은형태
      
      t.text :description
      t.timestamps
    end
  end
end
