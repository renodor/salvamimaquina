# frozen_string_literal:true

class UserMessageMailer < ApplicationMailer
  def contact_message(user_message:, subject:, to:)
    @user_message = user_message
    to = to.join(',') if to.is_a?(Array)
    mail to: to, subject: subject
  end
end
