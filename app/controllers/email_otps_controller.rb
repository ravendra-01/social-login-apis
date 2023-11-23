class EmailOtpsController < ApplicationController
  def create
    if params['email'].present?
      user = User.where(email: params['email']).first
      return render json: {
          otp: 'Account not found',
        }, status: :not_found if user.nil?

      email_otp = EmailOtp.new(email: params['email'])

      if email_otp.save
        send_email_for email_otp
        render json: {
          otp: 'Otp sent to registered email',
          pin: email_otp.pin,
          token: JsonWebToken.encode(
            email_otp.id,
            5.minutes.from_now,
            type: email_otp.class,
            user_id: user.id
          )
        }, status: :created
      else
        render json: {
          errors: [email_otp.errors]
        }, status: :unprocessable_entity
      end

    else
      return render json: {
        otp: 'Email required'
        }, status: :unprocessable_entity
    end
  end

  def otp_confirmation
    if params[:otp_code].present? && params[:new_password].present?
      begin
        token = JsonWebToken.decode(params[:token])
      rescue JWT::ExpiredSignature
        return render json: {
          errors: [{
            pin: 'OTP has expired, please request a new one.',
          }],
        }, status: :unauthorized
      rescue JWT::DecodeError => e
        return render json: {
          errors: [{
            token: 'Invalid token',
          }],
        }, status: :bad_request
      end

      begin
        otp = token.type.constantize.find(token.id)
      rescue ActiveRecord::RecordNotFound => e
        return render json: {
          errors: [{
            otp: 'OTP invalid',
          }],
        }, status: :unprocessable_entity
      end
      
      unless otp.pin == params[:otp_code].to_i && otp.activated == true
        return render json: {
          errors: [{
            otp: 'OTP code not validated'
          }] }, status: :unprocessable_entity
      else
        user = User.find(token.user_id)
        begin
          user.update!(password: params[:new_password])
        rescue ActiveRecord::RecordInvalid => e
          return render json: {
            errors: [{
              otp: 'Password invalid',
            }],
          }, status: :unprocessable_entity
        end
        otp.destroy
        render json: {
          messages: [{
            password: 'Password Updated successfully',
          }],
        }, status: :created
      end
    else
      return render json: {
        errors: [{
          otp: 'New Password and OTP code are required',
        }],
      }, status: :unprocessable_entity
    end
  end

  private

  def send_email_for(otp_record)
    # EmailOtpMailer
    #   .with(otp: otp_record, host: request.base_url)
    #   .otp_email.deliver
  end
end
