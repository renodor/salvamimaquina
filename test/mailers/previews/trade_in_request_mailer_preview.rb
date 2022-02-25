# frozen_string_literal:true

class TradeInRequestMailerPreview < ActionMailer::Preview
  def confirmation_email
    TradeInRequestMailer.confirmation_email(TradeInRequest.last)
  end
end
