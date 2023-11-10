# frozen_string_literal: true
require 'httparty'
require 'json'
class Users::SessionsController < DeviseTokenAuth::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    if params[:login_type] == "social"
      url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params["id_token"]}"                  
      response = HTTParty.get(url)                   
      @user = User.create_user_for_google(response.parsed_response)                
    else
      @user = User.find_by(email: params[:email])
      unless @user.valid_password?(params[:password])
        return render json: {
          status: { messages: "User could not be signed in successfully",
              errors: @user.errors.full_messages}
        }, status: :unprocessable_entity
      end
    end
    @user.save
    tokens = @user.create_new_auth_token
    set_headers(tokens)
    respond_with @user
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private
  def set_headers(tokens)
    headers['access-token'] = (tokens['access-token']).to_s
    headers['client'] =  (tokens['client']).to_s
    headers['expiry'] =  (tokens['expiry']).to_s
    headers['uid'] =@user.uid             
    headers['token-type'] = (tokens['token-type']).to_s
    headers['Authorization'] = (tokens['Authorization']).to_s                
  end

  def respond_with(resource, options={})
    if resource.persisted?
      render json: {
        status: { code: 200, messages: "User signed in successfully", data: resource}
      }
    else
      render json: {
        status: { messages: "User could not be signed in successfully",
            errors: resource.errors.full_messages}
      }, status: :unprocessable_entity
    end
  end
end
