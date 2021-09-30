class HomesController < ApplicationController
  def top
  end

  def guest_sign_in
    guest = User.find_or_initialize_by(email: 'guest@example.com')
    unless guest.persisted?
      guest.name = 'ゲスト'
      guest.year = 0
      guest.password = SecureRandom.urlsafe_base64
      guest.save
    end
    sign_in guest
    flash[:notice] = 'ゲストユーザとしてログインしました。'
    redirect_to users_path
  end
end
