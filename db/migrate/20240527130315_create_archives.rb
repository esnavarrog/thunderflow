class CreateArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :archives do |t|
      t.string :file
      t.references :archiveable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
