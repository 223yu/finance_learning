class AccountsController < ApplicationController

  def index
    @account = Account.new
    @accounts = Account.where(user_id: current_user.id, year: current_user.year).order(total_account: 'ASC').order(code: 'ASC')
  end

  def create
    @accounts = Account.where(user_id: current_user.id, year: current_user.year).order(total_account: 'ASC').order(code: 'ASC')
    @account = Account.new(account_params)
    @account.user_id = current_user.id
    @account.year = current_user.year
    if @account.save
      flash[:success] = "#{@account.name} を 合計科目:#{@account.total_account} に追加しました"
      redirect_to accounts_path
    else
      render 'index'
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    @account.update(account_params)
  end

  def destroy
    @account = Account.find(params[:id])
    @id = @account.id
    @account.destroy
  end

  private

    def account_params
      params.require(:account).permit(:code, :name, :total_account, :opening_balance_1)
    end

end
