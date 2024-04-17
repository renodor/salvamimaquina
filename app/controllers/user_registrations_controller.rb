# frozen_string_literal: true

class UserRegistrationsController < Devise::RegistrationsController
  before_action :check_permissions, only: %i[edit update]
  skip_before_action :require_no_authentication

  def create
    build_resource(spree_user_params)
    if resource.save
      set_flash_message(:notice, :signed_up)
      sign_in(:spree_user, resource)
      session[:spree_user_signup] = true
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with(resource) do |format|
        format.html { render :new, status: 422 }
      end
    end
  end

  def after_sign_up_path_for(resource)
    resource.is_a?(Spree::User) ? account_es_mx_path : root_path
  end

  protected

  def translation_scope
    'devise.user_registrations'
  end

  def check_permissions
    authorize!(:create, resource)
  end

  private

  def spree_user_params
    params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes | [:email])
  end
end
