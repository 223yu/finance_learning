class ApplicationController < ActionController::Base
  include AjaxHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :year])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  # フォームから送られてきた月選択の値を整える
  def select_start_month_to_end_month
    @get_start_month = 0
    @get_end_month = 0
    get_months = []
    get_months.push(params[:mon1])
    get_months.push(params[:mon2])
    get_months.push(params[:mon3])
    get_months.push(params[:mon4])
    get_months.push(params[:mon5])
    get_months.push(params[:mon6])
    get_months.push(params[:mon7])
    get_months.push(params[:mon8])
    get_months.push(params[:mon9])
    get_months.push(params[:mon10])
    get_months.push(params[:mon11])
    get_months.push(params[:mon12])

    n = 1
    get_months.each do |get_month|
      if @get_start_month == 0 && get_month.to_i == 1
        @get_start_month = n
        if n == 12 && @get_end_month == 0
          @get_end_month = 12
        end
        n += 1
      elsif get_month.to_i == 1
        @get_end_month = n
        n += 1
      elsif @get_start_month != 0 && @get_end_month == 0
        @get_end_month = @get_start_month
        n += 1
      else
        n += 1
      end
    end
  end

  # 非同期通信にて出力したflashメッセージを消す
  def discard_flash_if_xhr
    flash.discard if request.xhr?
  end

  # 貸借の残高を更新
  def update_debit_and_credit_balance(month, debit_id, credit_id, amount)
    debit_account = Account.find(debit_id)
    debit_account.update_balance(amount, month, 'debit')
    credit_account = Account.find(credit_id)
    credit_account.update_balance(amount, month, 'credit')
  end
end
