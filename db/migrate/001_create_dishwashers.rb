class CreateDishwashers < ActiveRecord::Migration
  def self.up
    create_table :dishwashers do |t|
      t.string :code
      t.string :status
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :dishwashers
  end
end
