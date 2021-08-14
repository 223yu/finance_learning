class AccountsController < ApplicationController
  after_action :discard_flash_if_xhr

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
      @account.update_opening_balance(0)
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
    prev_balance = @account.opening_balance_1.to_i
    @account.update(account_params)
    @account.update_opening_balance(prev_balance)
  end

  def destroy
    account = Account.find(params[:id])
    @id = account.id
    account.destroy
  end

  def search
    @account = Account.find_by(user_id: current_user.id, year: current_user.year, code: "#{params[:code]}")
    respond_to do |format|
      format.html
      format.json
    end
  end

  def search_sub
    @accounts = Account.where(user_id: current_user.id, year: current_user.year ).where("code LIKE ?", "%#{params[:code]}%")
    respond_to do |format|
      format.html
      format.json
    end
  end

  private

    def account_params
      params.require(:account).permit(:code, :name, :total_account, :opening_balance_1)
    end

end
