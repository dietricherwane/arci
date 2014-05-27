class QualificationsController < ApplicationController
  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def get_qualifications
    @department_id = params.first.first
    @qualifications_options = "<option>-Veuillez choisir une qualification-</option>"
    @qualifications = Department.find_by_id(@department_id).qualifications.where("published IS NOT FALSE")
    @qualifications.each do |qualification|
      @qualifications_options << "<option>#{qualification.label}</option>"
    end
    render :text => @qualifications_options
  end
  
  def create
    @error_messages = []
    @success_messages = []
    @department_id = params[:post][:qualification_department_id]
    @qualification = params[:qualification_name]
    @departments = Department.where("published IS NOT FALSE")
    @dropdown_departments = Department.order("name")
    @namecss = @qualification_namecss = @qualification_department_idcss = "row-form"
    
    if @department_id.blank? then @error_messages << "Veuillez d'abord choisir un département."; @qualification_department_idcss = "row-form error" end
    if @qualification.blank? then @error_messages << "Veuillez entrer le nom de la qualification à créer."; @qualification_namecss = "row-form error" end
    
    if !Qualification.where("name = '#{@name}' AND department_id = #{@department_id}").blank?
      @error_messages << "Une qualification portant ce nom existe déjà dans ce département."
    end
    
    if @error_messages.blank?
      @department = Department.find_by_id(@department_id)
      @department.qualifications.create(:label => @qualification.strip)
      @success_messages << "La qualification: #{@qualification.strip} a été ajoutée au département: #{@department.name}."
    end    
    render "/departments/index"
  end
  
  def edit
    @namecss = "row-form"
    @qualification = Qualification.find_by_id(params[:qualification_id])
    if @qualification.blank?
      redirect_to :back, :notice => "Cette qualification n'existe pas"
    else
      @departments = Department.all.order("name ASC")
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @departments = Department.all.order("name")
    @qualification = Qualification.find_by_id(params[:id])
    @existing_qualification = Qualification.find_by_label(@name)
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un nom de qualification"
      @namecss = "row-form error"
    end
    if !@existing_qualification.blank? and @existing_qualification.department_id == @qualification.id and @existing_qualification.id != params[:id].to_i
      @error_messages << "Une qualification portant ce nom existe déjà dans ce département."
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @qualification.update_attributes(:label => @name)
      @success_messages << "La qualification #{@name} a été modifiée."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:qualification_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:qualification_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @qualification = Qualification.find_by_id(id)
	  @qualification.blank? ? false : @qualification.update_attributes(published: bool)
	  redirect_to "/departments", :notice => "La qualification #{@qualification.label} a été #{status}."
	end

end
