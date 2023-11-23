class EmailOtp < ApplicationRecord
  
  validates :email, presence: true
  before_create :generate_pin_and_valid_date

  private
  
  def generate_pin_and_valid_date
    self.pin = rand(1_00000..9_99999)
    self.activated = true
    self.valid_until = Time.current + 10.minutes
  end
end