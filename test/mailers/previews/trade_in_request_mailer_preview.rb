# frozen_string_literal:true

class TradeInRequestMailerPreview < ActionMailer::Preview
  def confirmation_email
    TradeInRequestMailer.confirmation_email(TradeInRequest.last)
  end

  def admin_confirmation_email
    TradeInRequestMailer.admin_confirmation_email(TradeInRequest.last)
  end
end
