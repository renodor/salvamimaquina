# frozen_string_literal:true

class UserMessageMailer < ApplicationMailer
  def contact_message(contact)
    @contact = contact
    mail to: 'administracion@salvamimaquina.com', subject: 'New Message from salvamimaquina.com'
  end
end
