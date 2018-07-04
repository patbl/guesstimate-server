class AddUserIdToSpaceCheckpoint < ActiveRecord::Migration[4.2]
  def change
    add_column :space_checkpoints, :author_id, :integer
    add_index :space_checkpoints, :author_id
  end
end
