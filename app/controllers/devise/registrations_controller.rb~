class Devise::RegistrationsController < DeviseController
  #prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  #prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  #prepend_before_filter :authenticate_scope!, :only => [:new, :create, :cancel, :edit, :update, :destroy]
  #before_filter :authenticate_user!
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_scope!
  
  layout :layout_used
  # GET /resource/sign_up
  def new
    @users = User.all.order(:firstname, :lastname).page(params[:page]).per(8)
    @alert_messages = params[:alert_messages]
  	@profiles = Profile.where("published IS NOT FALSE").order("name ASC")
  	@departments = Department.where("published IS NOT FALSE").order("name ASC")
  	@firstnamecss = @lastnamecss = @uuidcss = @phone_numbercss = @mobile_numbercss = @emailcss = @passwordcss = @profile_idcss = @department_idcss = @qualificationcss = @password_confirmationcss = "row-form"
    build_resource({})
    respond_with self.resource
  end

  # POST /resource
  def create
    #build_resource(sign_up_params) 
    @users = User.all.order(:firstname, :lastname).page(params[:page]).per(8)
    @firstname = params[:user][:firstname]
    @lastname = params[:user][:lastname]
    @uuid = params[:user][:uuid]
    @phone_number = params[:user][:phone_number]
    @mobile_number = params[:user][:mobile_number]
    @email = params[:user][:email]
    @password = params[:user][:password]
    @password_confirmation = params[:user][:password_confirmation]
    @profile_id = params[:user][:profile_id]
    @external_partner_profile_id = Profile.find_by_name("Partenaire externe").id.to_s
    @department_id = params[:post][:department_id]
    @qualification = params[:qualification]
    @error = false
    @error_messages = []
    @profiles = Profile.where("published IS NOT FALSE")
  	@departments = Department.where("published IS NOT FALSE")
  	@phone_numbercss = "row-form"
  	
  	build_resource(params[:user])
    
    if @firstname.blank? then @error_messages << "Veuillez entrer le nom"; @firstnamecss = "row-form error" else @firstnamecss = "row-form" end
    if @lastname.blank? then @error_messages << "Veuillez entrer le prénom"; @lastnamecss = "row-form error" else @lastnamecss = "row-form" end
    if @uuid.blank? then @error_messages << "Veuillez entrer le matricule"; @uuidcss = "row-form error" else @uuidcss = "row-form" end
    if !@phone_number.blank? and not_a_number?(@phone_number) then @error_messages << "Le numéro de téléphone est un nombre sans espaces"; @phone_numbercss = "row-form error" else @phone_numbercss = "row-form" end
    if not_a_number?(@mobile_number) then @error_messages << "Le numéro de mobile doit être un nombre sans espaces"; @mobile_numbercss = "row-form error" else @mobile_numbercss = "row-form" end 
    if @password_confirmation.blank? then @password_confirmationcss = "row-form error" else @passwordcss.blank? ? @password_confirmationcss = "row-form" : false end     
    if !User.find_by_email(@email).nil? then @error_messages << "Cette adresse email existe déjà"; @emailcss = "row-form error"; @password_confirmationcss = "row-form" else @emailcss = "row-form" end
    if (@email.empty?) then @error_messages << "Veuillez entrer un email valide"; @emailcss = "row-form error" else @emailcss.blank? ? @emailcss = "row-form" : false end
    if @password != @password_confirmation then @error_messages << "Le mot de passe et sa confirmation doivent être identiques"; @passwordcss = "row-form error"; @password_confirmationcss = "row-form error" else @passwordcss = "row-form" end
    if @password.blank? then @error_messages << "Veuillez entrer un mot de passe"; @passwordcss = "row-form error" else @passwordcss.blank? ? @passwordcss = "row-form" : false end   
    if @profile_id.blank?
      @error_messages << "Veuillez choisir un profil"; @profile_idcss = "row-form error" 
    else 
      @profile_idcss = "row-form" 
    end
    if @department_id.blank? and !@external_partner_profile_id.eql?(@profile_id) then @error_messages << "Veuillez assigner l'utilisateur à un département"; @department_idcss = "row-form error" else @department_idcss = "row-form" end
    if ((@qualification.blank? or @qualification.eql?("-Veuillez choisir une qualification-")) and !@external_partner_profile_id.eql?(@profile_id)) then @error_messages << "Veuillez choisir une qualification"; @department_idcss = @qualificationcss = "row-form error" else @department_idcss = @qualificationcss = "row-form" end

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        # un partenaire externe n'appartient à aucun département ni n'a de qualification
        if @external_partner_profile_id.eql?(@profile_id)
          resource.update_attributes(firstname: capitalization(@firstname), lastname: capitalization(@lastname), phone_number: @phone_number, mobile_number: @mobile_number, profile_id: @profile_id)
        else
          resource.update_attributes(firstname: capitalization(@firstname), lastname: capitalization(@lastname), phone_number: @phone_number, mobile_number: @mobile_number, profile_id: @profile_id, department_id: @department_id, qualification_id: Qualification.find_by_label(@qualification).id)
        end
        @alert_messages = ["L'utilisateur a été créé. Néanmoins, il doit activer son compte via le lien reçu dans sa boîte de messagerie."]
        redirect_to administrator_dashboard_path, :alert_messages => @alert_messages
        #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
    	#resource.errors[:firstname] << params[:user]
      clean_up_passwords resource
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    @error_messages = params[:error_messages]
    @duke = params
    @users = User.all.order(:firstname, :lastname).page(params[:page]).per(8)
    @user = User.find_by_id(params[:id])
    @profiles = Profile.where("published IS NOT FALSE")
  	@departments = Department.where("published IS NOT FALSE")
  	@firstnamecss = @lastnamecss = @uuidcss = @phone_numbercss = @mobile_numbercss = @profile_idcss = @department_idcss = @qualificationcss = "row-form"
    render :edit
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if resource.update_with_password(account_update_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  
  def update_profile
    @users = User.all.order(:firstname, :lastname).page(params[:page]).per(8)
    @user = User.find_by_id(params[:id])
    @profiles = Profile.where("published IS NOT FALSE")
  	@departments = Department.where("published IS NOT FALSE")
  	@firstnamecss = @lastnamecss = @uuidcss = @phone_numbercss = @mobile_numbercss = @profile_idcss = @department_idcss = @qualificationcss = "row-form" 
    @firstname = params[:user][:firstname]
    @lastname = params[:user][:lastname]
    @uuid = params[:user][:uuid]
    @phone_number = params[:user][:phone_number]
    @mobile_number = params[:user][:mobile_number]
    @profile_id = params[:user][:profile_id]
    @department_id = params[:post][:department_id]
    @qualification = params[:qualification]
    @error_messages = []
    @success_messages = []
    @external_partner_profile_id = Profile.find_by_name("Partenaire externe").id.to_s
    
    if @firstname.blank? then @error_messages << "Veuillez entrer le nom"; @firstnamecss = "row-form error" else @firstnamecss = "row-form" end
    if @lastname.blank? then @error_messages << "Veuillez entrer le prénom"; @lastnamecss = "row-form error" else @lastnamecss = "row-form" end
    if @uuid.blank? then @error_messages << "Veuillez entrer le matricule"; @uuidcss = "row-form error" else @uuidcss = "row-form" end
    if !@phone_number.blank? and not_a_number?(@phone_number) then @error_messages << "Le numéro de téléphone est un nombre sans espaces"; @phone_numbercss = "row-form error" else @phone_numbercss = "row-form" end
    if not_a_number?(@mobile_number) then @error_messages << "Le numéro de mobile est un nombre sans espaces"; @mobile_numbercss = "row-form error" else @mobile_numbercss = "row-form" end 
    if @profile_id.blank? then @error_messages << "Veuillez choisir un profil"; @profile_idcss = "row-form error" else @profile_idcss = "row-form" end    
    if (@qualification.blank? or @qualification.eql?("-Veuillez choisir une qualification-")) then @qualification_id = @user.qualification_id else @qualification_id = Qualification.find_by_label(@qualification).id end
    if @department_id.blank? then @department_id = @user.department_id; @qualification_id = @user.qualification_id else false end
    
    if @error_messages.blank?
      @user.update_attributes(firstname: @firstname, lastname: @lastname, uuid: @uuid, phone_number: @phone_number, mobile_number: @mobile_number, profile_id: @profile_id, department_id: @department_id, qualification_id: @qualification_id)
      if @external_partner_profile_id.eql?(@profile_id)
        @user.update_attributes(firstname: @firstname, lastname: @lastname, uuid: @uuid, phone_number: @phone_number, mobile_number: @mobile_number, profile_id: @profile_id, department_id: nil, qualification_id: nil)
      else
        @user.update_attributes(firstname: @firstname, lastname: @lastname, uuid: @uuid, phone_number: @phone_number, mobile_number: @mobile_number, profile_id: @profile_id, department_id: @department_id, qualification_id: @qualification_id)
      end
      @success_messages << "Le profil a été mis à jour"
    end
    render :edit
  end

  # DELETE /resource
  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_registration_path(resource_name)
  end

  protected

  def update_needs_confirmation?(resource, previous)
    resource.respond_to?(:pending_reconfirmation?) &&
      resource.pending_reconfirmation? &&
      previous != resource.unconfirmed_email
  end

  # Build a devise resource passing in the session. Useful to move
  # temporary session data to the newly created user.
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    respond_to?(:root_path) ? root_path : "/"
  end

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # Authenticates the current scope and gets the current resource from the session.
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send(:"current_#{resource_name}")
  end

  def sign_up_params
    devise_parameter_sanitizer.for(:sign_up)
  end

  def account_update_params
    devise_parameter_sanitizer.for(:account_update)
  end
end
