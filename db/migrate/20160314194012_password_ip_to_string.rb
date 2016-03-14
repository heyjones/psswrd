class PasswordIpToString < ActiveRecord::Migration
  def change
    change_column :passwords, :ip, :string
  end
end
