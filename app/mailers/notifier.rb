class Notifier < ActionMailer::Base
  default from: "Arci"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.send_request.subject
  #
  def send_request(sender_name, sender_qualification, receiver, books)
    @books = books
    @sender_name = sender_name
    @sender_qualification = sender_qualification
    
    mail :bcc => receiver, :subject => "Nouvelle demande de documents", :from => sender_name
  end
  
  def csadp_request_validation(sender_name, sender_qualification, receiver, demand_date, message)
    @sender_name = sender_name
    @sender_qualification = sender_qualification
    @demand_date = demand_date
    @message = message
    
    mail :bcc => receiver, :subject => "Validation de votre demande de documents par le Chef du Service d'Archivage de Données", :from => sender_name
  end
  
  def employee_request_validation(sender_name, sender_qualification, receiver, demand_date, message)
    @sender_name = sender_name
    @sender_qualification = sender_qualification
    @demand_date = demand_date
    @message = message
  
    mail :bcc => receiver, :subject => "Nouvelle demande de documents", :from => sender_name
  end
  
  def agc_request_validation(sender_name, sender_qualification, receiver, demand_date, message)
    @sender_name = sender_name
    @sender_qualification = sender_qualification
    @demand_date = demand_date
    @message = message
  
    mail :bcc => receiver, :subject => "Validation de votre demande de documents par un agent du centre", :from => sender_name
  end
  
  def employee_request_return_or_damage(sender_name, sender_qualification, receiver, demand_date)
    @sender_name = sender_name
    @sender_qualification = sender_qualification
    @demand_date = demand_date
    
    mail :bcc => receiver, :subject => "Retour de documents empruntés", :from => sender_name
  end
  
  def send_reminder(user)
    @user = user
    @demand_ids = ActiveRecord::Base.connection.execute("SELECT DISTINCT demand_id FROM books_demands WHERE taken IS TRUE AND returned IS NULL AND book_damaged IS NULL AND taken_by_at < '#{DateTime.now - 5.days}'AND user_id = #{@user.id}").map{ |book_demand| book_demand["demand_id"] }
    @demand_ids = @demand_ids.uniq
    
    mail :bcc => user.email, :subject => "Retour de documents empruntés", :from => "ARCI"
  end
  
end
