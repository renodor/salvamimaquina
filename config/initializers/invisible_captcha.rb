# frozen_string_literal:true

InvisibleCaptcha.setup do |config|
  config.timestamp_threshold     = 6
  config.sentence_for_humans     = 'Por favor dejar este campo invisible'
  config.timestamp_error_message = 'Hubo un problema mandando su mensaje. Por favor reintentar'
end