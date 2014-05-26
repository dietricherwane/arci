class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :sign_out_disabled_users
	before_action :set_user, only: [:edit_profile, :update_profile]
	
	def dashboard
	
	end	
	
	def edit_profile
	
	end
	
	def search
		user = Elasticsearch::Client.new log: false
		user.transport.reload_connections!
		user.cluster.health
		user.search q: 'dietrich'
	end
	
	def update_profile
    if @user.update(user_params)
    	redirect_to :back, notice: 'User was successfully updated.'
    else
    	render action: 'edit_profile'
    end
	end
	
	def enable_profile
	  enable_disable_profile(params[:id], true, "activé")
	  redirect_to "/user/edit_profile/#{params[:id]}", :notice => "Le compte de [ #{@user.full_name} | #{@user.profile} ] a été #{@status}."
	end
	
	def disable_profile
	  enable_disable_profile(params[:id], false, "désactivé")
	  redirect_to "/user/edit_profile/#{params[:id]}", :notice => "Le compte de [ #{@user.full_name} | #{@user.profile} ] a été #{@status}."
	end
	
	def enable_disable_profile(id, bool, status)
	  @status = status
	  @user = User.find_by_id(id)
	  @user.blank? ? false : @user.update_attributes(published: bool)	  
	end
	
	private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:firstname, :lastname, :phone_number, :mobile_number)
    end
	
end
