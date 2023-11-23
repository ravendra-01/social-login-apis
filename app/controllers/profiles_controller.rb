class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def change_password
    if params[:new_password]
      begin
        current_user.update!(password: params[:new_password])
      rescue ActiveRecord::RecordInvalid => e
        return render json: {
          errors: [{
            otp: 'Password invalid',
          }],
        }, status: :unprocessable_entity
      end
      render json: {
        messages: [{
          password: 'Password Updated successfully',
        }],
      }, status: :created
    else
      render json: {
        errors: [{
          otp: 'New Password are required',
        }],
      }, status: :unprocessable_entity
    end
  end
end