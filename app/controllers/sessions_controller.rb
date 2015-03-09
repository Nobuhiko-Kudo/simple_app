class SessionsController < ApplicationController

	def new
	end
	
	def create
		session[:user] = User.find_by(email: params[:email].downcase)
		user = session[:user]
		if user && user.authenticate(params[:password])
			#ユーザをサインインさせ、ユーザーページ（show）にリダイレクトする。
			sign_in user
			redirect_back_or user
		else
			#エラーメッセージを表示し、サインインフォームを再描画する。
			flash.now[:error] = 'Invalid email/password combination'
			render 'new'
		end
	end
	
	def destroy
		sign_out
		redirect_to root_url
	end
end
