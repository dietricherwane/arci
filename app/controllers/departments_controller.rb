class DepartmentsController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def index
    @departments = Department.where("published IS NOT FALSE")
    @dropdown_departments = Department.order("name")
    @namecss = @qualification_namecss = @qualification_department_idcss = "row-form"
  end
  
  def create
    @name = params[:name]
    @qualification_namecss = @qualification_department_idcss = "row-form"
    @error_messages = []
    @success_messages = []
    @departments = Department.all.order("name")
    @dropdown_departments = Department.order("name")
    
    if @name.blank? then @error_messages << "Veuillez entrer le nom du département à créer."; @namecss = "row-form error" else @namecss = "row-form" end
    
    if @error_messages.blank?
      Department.create(:name => @name.strip)
      @success_messages << "Le département #{@name.strip} a été créé."
    end   
    render :index
  end
  
end
