class User < ActiveRecord::Base

	before_save { self.email = email.downcase }

	#before_saveの書き換え
	#before_save { self.email = email.downcase }
	before_save { email.downcase! }

	
	has_secure_password

	validates :name, presence: true, length: { maximum:50 }

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

#	正規表現の書き換え
#	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

	validates :email, presence: true, 
					  format: { with: VALID_EMAIL_REGEX}, 
					  uniqueness: { case_sensitive: false }

	validates :password, length: { minimum: 6 }
end
