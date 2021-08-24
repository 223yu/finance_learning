class LedgersController < ApplicationController
  before_action :authenticate_user!
  before_action :select_start_month_to_end_month, only:[:index]

  def select
    @accounts = current_user.accounts_index
  end

  def index
    # 試算表からリンクで飛んできている（同期処理）場合、viewに受け渡すパラメータを調整
    if params[:start_month] != nil
      @get_start_month = params[:start_month].to_i
      @get_end_month = params[:end_month].to_i
      @accounts = current_user.accounts_index
    end
    @self_code = params[:self_code]
    if @get_start_month == 0 || @self_code == ''
      flash[:danger] = '表示する月と科目を選択してください。'
      respond_to do |format|
        format.js { render ajax_redirect_to(request.referer) }
      end
    else
      @account = Account.find_by(user_id: current_user.id, year: current_user.year, code: @self_code)
      range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
      @journals = current_user.journal_index_from_self_code_in_ledger(@self_code, range)
    end
  end

end
