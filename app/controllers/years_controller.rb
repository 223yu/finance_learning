class YearsController < ApplicationController

  def select
    year = params[:year]
    if current_user.update(year: year)
      flash[:success] = "#{year}年度に切り替えました"
      redirect_to users_path
    else
      flash[:danger] = '問題が発生しました。再度実行してください。'
      render 'users/show'
    end
  end

  def update
  end

end
