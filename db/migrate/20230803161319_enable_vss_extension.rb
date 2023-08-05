class EnableVssExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension :sqlite_vss
  end
end