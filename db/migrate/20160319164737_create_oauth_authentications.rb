class CreateOauthAuthentications < ActiveRecord::Migration[4.2]
  def change
    create_table :oauth_authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :nickname
      t.string :image
      t.string :access_token
      t.string :secret_token
      t.text :auth_hash

      t.timestamps null: false
    end
  end
end
