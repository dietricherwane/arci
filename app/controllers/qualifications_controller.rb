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
    
    if @error_messages.blank?
      @department = Department.find_by_id(@department_id)
      @department.qualifications.create(:label => @qualification.strip)
      @success_messages << "La qualification: #{@qualification.strip} a été ajoutée au département: #{@department.name}."
    end    
    render "/departments/index"
  end

end
