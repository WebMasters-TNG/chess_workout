class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :old_x
      t.integer :old_y
      t.integer :new_x
      t.integer :new_y
      t.integer :move_count
      t.boolean :captured_piece
      t.integer :game_id
      t.integer :piece_id

      t.timestamps
    end
  end
end
