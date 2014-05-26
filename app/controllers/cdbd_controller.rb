class CdbdController < ApplicationController
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used
  
  def list_library_agents
    @agent_profile = Profile.find_by_name("Agent du centre")
    @agents = User.where("profile_id = #{@agent_profile.id}").order("firstname ASC, lastname ASC")
  end
  
  def give_validation_right
    @agent_profile = Profile.find_by_name("Agent du centre")
    @agents = User.where("profile_id = #{@agent_profile.id}").order("firstname ASC, lastname ASC")
    @success_messages = []

    @agent = User.find_by_id(params[:id])
    @agent.update_attributes(can_validate: true)
    @success_messages << "L'agent: #{@agent.full_name} a maintenant le droit de valider des demandes de documents"
    render :action => "list_library_agents"
  end
  
  def remove_validation_right
    @agent_profile = Profile.find_by_name("Agent du centre")
    @agents = User.where("profile_id = #{@agent_profile.id}").order("firstname ASC, lastname ASC")
    @success_messages = []
    
    @agent = User.find_by_id(params[:id])
    @agent.update_attributes(can_validate: false)
    @success_messages << "L'agent: #{@agent.full_name} n'a plus le droit de valider des demandes de documents"
    render :action => "list_library_agents"
  end
end
