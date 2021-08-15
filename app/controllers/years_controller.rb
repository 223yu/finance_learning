class YearsController < ApplicationController
  before_action :authenticate_user!

  def select
    year = params[:year]
    if current_user.update(year: year)
      flash[:success] = "#{year}年度に切り替えました"
      redirect_to users_path
    else
      flash[:danger] = '問題が発生しました。再度実行してください。'
      redirect_to users_path
    end
  end

  def update
    year = params[:year].to_i
    current_user.update_year(year)
    if current_user.update(year: year + 1)
      flash[:success] = "#{year + 1}年度のデータを更新しました"
      redirect_to users_path
    else
      flash[:danger] = '問題が発生しました。再度実行してください。'
      redirect_to users_path
    end
  end

end
