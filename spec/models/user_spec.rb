require 'spec_helper'

describe User do
 before do
 	User.destroy_all
 	@user = User.new(name: "Example User", email: "user@example.com", 
 						password: "foobar", password_confirmation: "foobar")
 end	
 
 subject{ @user }
 
 it { is_expected.to respond_to(:name) }
 it { is_expected.to respond_to(:email) }
 it { is_expected.to respond_to(:password_digest) }
 it { is_expected.to respond_to(:password) }
 it { is_expected.to respond_to(:password_confirmation) }
 it { is_expected.to respond_to(:remember_token) }
 it { is_expected.to respond_to(:authenticate) }
 it { is_expected.to respond_to(:admin) }
 it { is_expected.to respond_to(:microposts) }
 it { is_expected.to respond_to(:feed) }
 it { is_expected.to respond_to(:relationships) } 
 it { is_expected.to be_valid }
 
 describe "with admin attributes set to 'true'" do
	 before do
		 @user.save!
		 @user.toggle!(:admin)
	 end

	 it { is_expected.to be_admin }
 end

 describe "when name is not present" do
 	before { @user.name=" " }
 	it { is_expected.not_to be_valid }
 end
  
 describe "when email is not present" do
 	before { @user.email=" " }
 	it { is_expected.not_to be_valid }
 	it { is_expected.not_to be_valid }
 end
 
 describe "when password is not present" do
 	before do
 		@user = User.new(name: "Example User", email: "user@example.com", 
  						password:" ", password_confirmation:" ")
  	end
  	it { is_expected.not_to be_valid }
  	it { is_expected.not_to be_valid }
 end
 
 describe "when name is too long" do
 	before { @user.name = "a" * 51 }
 	it { is_expected.not_to be_valid }
 	it { is_expected.not_to be_valid }
 end
 
 describe "when email format is invalid" do
 	it "should be invalid" do
 		addresses = %w[user@foo,com user_at_foo,org example.user@foo.foo@bar_baz.com foo@bar+baz.com]
 		addresses = %w[user@foo,com user_at_foo,org example.user@foo.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
 		addresses.each do |invaled_address|
 			@user.email = invaled_address
 			expect(@user).not_to be_valid
 		end
	end
 end

 describe "when email format is valid" do
 	it "should be valid" do
 		addresses = %w[user@foo.COM A_US_ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
 		addresses.each do |valid_address|
 			@user.email = valid_address
 			expect(@user).to be_valid
 		end
 	end
 end
 
 describe "when email address is already taken" do
 	before do
 		user_with_same_email = @user.dup
 		user_with_same_email.email = @user.email.upcase
 		user_with_same_email.save
 	end
 	
 	it { is_expected.not_to be_valid }
 	it { is_expected.not_to be_valid }
 end
 
 describe "when password doesn't match confirmation" do
 	before { @user.password_confirmation = "mismatch" }
 	it { is_expected.not_to be_valid }
 end
 
 describe "with a password that's too short" do
 	before { @user.password = @user.password_confirmation = 'a' * 5 }
 	it { is_expected.to be_invalid }
 end
 
 describe "return value of authenticate method" do
 	before do
 		User.destroy_all
 		@user.save
 	end
 	let(:found_user) { User.find_by(email: @user.email)}
 	
 	describe "with valid password" do
 		it{ is_expected.to eq found_user.authenticate(@user.password) }
 	end
 	
 	describe "with invalid password" do
 		let(:user_for_invalid_password){ found_user.authenticate("invalid") }
 		
 		it{ is_expected.not_to eq user_for_invalid_password }
 		specify { expect(user_for_invalid_password).to be_falsy }
 	end
 end
 
 describe "email address with mixed case" do
 	let(:mixed_case_email){ "Foo@ExAMPle.CoM" }
 	
 	it "should be saved as all lower-case" do
 		@user.email = mixed_case_email
 		@user.save
 		expect(@user.reload.email).to eq mixed_case_email.downcase
 	end
 end
 
 describe "remember token" do
 	before do
 		User.destroy_all
 		@user.save
 	end

	describe '#remember_token' do
	  subject { super().remember_token }
	  it { is_expected.not_to be_blank }
	end
 end

 describe "micropost associations" do

	 before { @user.save }
	 let!(:older_micropost) do
		 FactoryGirl.create(:micropost, user:@user, created_at:1.day.ago)
	 end

	 let!(:newer_micropost) do
		 FactoryGirl.create(:micropost,user: @user, created_at: 1.hour.ago)
	 end

	 it "should have the right microposts in the right order" do
		 expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
	 end
   
   it "should destroy associated microposts" do
     microposts = @user.microposts.to_a
     @user.destroy
     expect(microposts).not_to be_empty
     microposts.each do |micropost|
       expect(Micropost.where(id:micropost.id)).to be_empty
     end
   end

   describe "status" do
     let(:unfollowed_post) do
       FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
     end

     its(:feed) { should include(newer_micropost) }
     its(:feed) { should include(older_micropost) }
     its(:feed) { should_not include(unfollowed_post) }
   end
 end
end
