class TrialBalancesController < ApplicationController
  before_action :authenticate_user!
  before_action :select_start_month_to_end_month, only: [:index]

  def select
  end

  def index
    # 月が選択されていない状態で「表示」ボタンが押された場合redirectする
    if @get_start_month == 0
      flash[:danger] = '表示する月を選択してください。'
      respond_to do |format|
        format.js { render ajax_redirect_to(request.referer) }
      end
    else
      @accounts = Account.where(user_id: current_user.id, year: current_user.year)
    end
  end
end
