# frozen_string_literal:true

class ReparationRequestMailer < ApplicationMailer
  def reparation_request_message(reparation_request:)
    @reparation_request = reparation_request
    mail to: 'administracion@salvamimaquina.com', from: 'administracion@salvamimaquina.com', subject: 'New reparation request from www.salvamimaquina.com'
  end
end
