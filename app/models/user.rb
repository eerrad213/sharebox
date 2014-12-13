class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	     :recoverable, :rememberable, :trackable, :validatable

	#  Setup accessible (or protected) attributes for your model 
	def user_params
	  params.require(:user).permit(:email, :name, :password, :password_confirmation, :remember_me)
	end

	 validates :email, :presence => true, :uniqueness => true

	has_many :assets
	has_many :folders
end
