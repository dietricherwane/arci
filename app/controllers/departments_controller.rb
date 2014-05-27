class DepartmentsController < ApplicationController

  before_filter :sign_out_disabled_users
  prepend_before_filter :authenticate_user!
  
  layout :layout_used

  def index
    @departments = Department.all.order("name ASC")
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
  
  def edit
    @namecss = "row-form"
    @department = Department.find_by_id(params[:department_id])
    if @department.blank?
      redirect_to :back, :notice => "Ce département n'existe pas"
    else
      @departments = Department.all.order("name ASC")
    end    
  end
  
  def update
    @name = params[:name].strip
    @error_messages = []
    @success_messages = []
    @departments = Department.all.order("name")
    @department = Department.find_by_id(params[:id])
    @namecss = "row-form"
    
    if @name.blank?
      @error_messages << "Veuillez entrer un nom de département"
      @namecss = "row-form error"
    end
    if !@department.blank? and @department.id != params[:id].to_i
      @error_messages << "Un département portant ce nom existe déjà"
      @namecss = "row-form error"
    end
    
    if @error_messages.blank?
      @department.update_attributes(:name => @name)
      @success_messages << "Le département #{@name} a été modifié."
    end   
    render :edit
  end
  
  def enable
	  enable_disable(params[:department_id], true, "activé")
	end
	
	def disable
	  enable_disable(params[:department_id], false, "désactivé")
	end
	
	def enable_disable(id, bool, status)
	  @department = Department.find_by_id(id)
	  @department.blank? ? false : @department.update_attributes(published: bool)
	  redirect_to "/departments", :notice => "Le département #{@department.name} a été #{status}."
	end
  
end
