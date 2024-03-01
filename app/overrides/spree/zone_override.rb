# frozen_string_literal: true

require 'active_support/concern'

module Spree
  module ZoneOverride
    extend ActiveSupport::Concern

    prepended do
      scope :with_member_ids, lambda { |state_ids, country_ids, district_ids|
        if state_ids.blank? && country_ids.blank? && district_ids.blank?
          none
        else
          matching_state = find_matching_location('Spree::State', state_ids)
          matching_country = find_matching_location('Spree::Country', country_ids)
          matching_district = find_matching_location('Spree::District', district_ids)
          joins(:zone_members).where(matching_state.or(matching_country).or(matching_district)).distinct
        end
      }

      scope :for_address, ->(address) { address ? with_member_ids(address.state_id, address.country_id, address.district_id) : none }
    end

    class_methods do
      def find_matching_location(location_type, location_ids)
        spree_zone_members_table = Spree::ZoneMember.arel_table
        spree_zone_members_table[:zoneable_type].eq(location_type).and(spree_zone_members_table[:zoneable_id].in(location_ids))
      end
    end

    def district_ids
      if kind == 'district'
        members.pluck(:zoneable_id)
      else
        []
      end
    end

    def district_ids=(ids)
      set_zone_members(ids, 'Spree::District')
    end

    Spree::Zone.prepend self
  end
end
