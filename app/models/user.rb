class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :encryptable, :encryptor => :sha1
  attr_accessible :email, :password, :password_confirmation
end
