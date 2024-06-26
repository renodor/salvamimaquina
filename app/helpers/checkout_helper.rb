# frozen_string_literal: true

module CheckoutHelper
  def partial_name_with_fallback(prefix, partial_name, fallback_name = 'default')
    if lookup_context.find_all("#{prefix}/_#{partial_name}").any?
      "#{prefix}/#{partial_name}"
    else
      "#{prefix}/#{fallback_name}"
    end
  end

  def checkout_progress_custom
    states = checkout_states
    items = states.map do |state|
      text = I18n.t("spree.order_state.#{state}").titleize

      css_classes = []
      current_index = states.index(@order.state)
      state_index = states.index(state)

      if state_index < current_index
        css_classes << 'completed'
        text = link_to text, checkout_state_path(state)
      end

      css_classes << 'next' if state_index == current_index + 1
      css_classes << 'current' if state == @order.state
      css_classes << 'first' if state_index.zero?
      css_classes << 'last' if state_index == states.length - 1
      content_tag('div', content_tag('span', text), class: css_classes) # include separated classes instead of the original joined ones
    end
    content_tag('div', raw(items.join("\n")), class: 'progress-steps', id: "checkout-step-#{@order.state}")
  end

  def district_select_options(address)
    address.state.districts.map do |district|
      [district.name, district.id, { data: { latitude: district.latitude, longitude: district.longitude } }]
    end
  end
end
