# frozen_string_literal:true

module FlashHelper
  def render_turbo_stream_flash_messages
    turbo_stream.replace 'flash', partial: 'shared/flash'
  end
end
