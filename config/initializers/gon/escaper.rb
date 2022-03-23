# frozen_string_literal:true

# Rewriting this module found here: https://github.com/gazay/gon/blob/master/lib/gon/escaper.rb
# in order to add the data-turbolinks-track=reload to Gon <script> tag
# (Otherwise Gon and turbolinks don't play well together and sometimes the script tag is not reloaded and gon variables are lost)
class Gon
  module Escaper
    extend ActionView::Helpers::JavaScriptHelper
    extend ActionView::Helpers::TagHelper

    class << self
      def escape_unicode(javascript)
        return unless javascript

        result = escape_line_separator(javascript)
        javascript.html_safe? ? result.html_safe : result
      end

      def javascript_tag(content, type, cdata, nonce)
        options = {}
        options.merge!({ type: 'text/javascript' }) if type
        options.merge!({ nonce: nonce }) if nonce
        options.merge!({ 'data-turbolinks-track' => 'reload' })

        content_tag(:script, javascript_cdata_section(content, cdata).html_safe, options)
      end

      def javascript_cdata_section(content, cdata)
        if cdata
          "\n//#{cdata_section("\n#{content}\n//")}\n"
        else
          "\n#{content}\n"
        end
      end

      private

      def escape_line_separator(javascript)
        javascript.gsub(/\\u2028/u, '&#x2028;')
      end
    end
  end
end
