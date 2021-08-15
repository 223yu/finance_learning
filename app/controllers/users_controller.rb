class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @cash_array = current_user.return_balance_array('現預金')
    @profit_array = current_user.return_profit_balance_array
  end

  def start
    year = params[:year]
    if current_user.accounts_setting(year)
      flash[:success] = "#{year}年度のデータを作成しました"
      redirect_to users_path
    else
      flash[:danger] = '問題が発生しました。再度実行してください。'
      render 'show'
    end
  end

end
