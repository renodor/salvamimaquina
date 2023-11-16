# frozen_string_literal:true

module FlashHelper
  def build_flash(type, message)
    content_tag :div, class: "flash #{type}" do
      concat(content_tag(:span, message))
      concat(svg('cross', class: 'close-flash'))
    end
  end
end