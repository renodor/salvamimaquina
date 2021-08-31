# frozen_string_literal:true

module ApplicationHelper
  def svg(file_name, **args)
    options = {}
    options[:class] = args[:class].present? ? args[:class] : ''
    # options[:class] += args[:extra_class].present? ? " #{args[:extra_class]}" : ''

    # Create the path to the svgs directory
    file_path = "#{Rails.application.root}/app/assets/images/svgs/#{file_name}"
    file_path = "#{file_path}.svg" unless file_path.end_with? '.svg'

    # Create a cache hash
    hash = Digest::MD5.hexdigest "#{file_path.underscore}_#{options}"

    svg_content = Rails.cache.fetch "svg_file_#{hash}", expires_in: 1.year, cache_nils: false do
      if File.exist?(file_path)
        file = File.read(file_path)

        # parse svg
        doc = Nokogiri::HTML::DocumentFragment.parse file
        svg = doc.at_css 'svg'

        # attach options
        options.each do |attr, value|
          svg[attr.to_s] = value
        end

        # cast to html
        doc.to_html.html_safe
      end
    end

    return '(not found)' if svg_content.to_s.blank?

    svg_content
  end
end
