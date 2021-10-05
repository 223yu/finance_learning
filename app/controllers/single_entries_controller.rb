class SingleEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :select_start_month_to_end_month, only: [:index]
  after_action :discard_flash_if_xhr

  def select
  end

  def index
    if params[:start_month]
      # search mode
      # 日付の入力が正しければ採用し、入力がないor誤りの場合、最初に選択した期間を採用
      @get_start_month = params[:start_month].to_i
      @get_end_month = params[:end_month].to_i
      if Date.valid_date?(current_user.year, params[:month].to_i, params[:day].to_i)
        range = Date.new(current_user.year, params[:month].to_i, params[:day].to_i)
      else
        range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
      end
      # 入力された内容で検索
      @journals = Journal.where(user_id: current_user.id, date: range).order(id: 'DESC').limit(15).offset(0)
      @journals = @journals.where(debit_id: current_user.code_id(params[:debit_code].to_i)) unless params[:debit_code] == ''
      @journals = @journals.where(credit_id: current_user.code_id(params[:credit_code].to_i)) unless params[:credit_code] == ''
      @journals = @journals.where(amount: params[:amount]) unless params[:amount] == ''
      @journals = @journals.where('description LIKE ?', "%#{params[:description]}%") unless params[:description] == ''

      @journal = Journal.new
    else
      # nomal mode
      # 月が選択されていない状態で「表示」ボタンが押された場合redirectする
      if @get_start_month == 0
        flash[:danger] = '表示する月を選択してください。'
        respond_to do |format|
          format.js { render ajax_redirect_to(request.referer) }
        end
      else
        range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
        @journals = Journal.where(user_id: current_user.id, date: range).order(id: 'DESC').limit(15).offset(0)
        @journal = Journal.new
      end
    end
  end

  def create
    @journal = Journal.new(journal_params)
    if @journal.self_create_and_update_account_balance(current_user)
      @journal_new = Journal.new
    else
      flash[:danger] = '入力が正しくない項目があります'
    end
  end

  def edit
    @journal = Journal.find(params[:id])
    @journal.arrange_for_display
  end

  def update
    @journal = Journal.find(params[:id])
    unless @journal.self_update_and_update_account_balance(current_user, journal_params)
      flash[:danger] = '入力が正しくない項目があります'
      @journal.arrange_for_display
    end
  end

  def destroy
    journal = Journal.find(params[:id])
    @id = journal.id
    unless journal.delete_after_updating_balance
      falsh[:danger] = '仕訳の削除に失敗しました'
    end
  end

  def search
    @start_month = params[:start_month]
    @end_month = params[:end_month]
    @activated = params[:activated]
    @journal = Journal.new
  end

  def scroll
    # 日付の入力が正しければ採用し、入力がないor誤りの場合、最初に選択した期間を採用
    start_month = params[:start_month].to_i
    end_month = params[:end_month].to_i
    if Date.valid_date?(current_user.year, params[:month].to_i, params[:day].to_i)
      range = Date.new(current_user.year, params[:month].to_i, params[:day].to_i)
    else
      range = current_user.start_date_to_end_date(start_month, end_month)
    end
    # データの取得
    offset = params[:offset]
    @journals = Journal.where(user_id: current_user.id, date: range).order(id: 'DESC').limit(15).offset(offset)
    # 検索ワードがあれば絞り込み
    @journals = @journals.where(debit_id: current_user.code_id(params[:debit_code].to_i)) unless params[:debit_code] == ''
    @journals = @journals.where(credit_id: current_user.code_id(params[:credit_code].to_i)) unless params[:credit_code] == ''
    @journals = @journals.where(amount: params[:amount]) unless params[:amount] == ''
    @journals = @journals.where('description LIKE ?', "%#{params[:description]}%") unless params[:description] == ''

    @journals.each do |journal|
      journal.arrange_for_display
    end

  end

  private

  def journal_params
    params.require(:journal).permit(:month, :day, :debit_code, :credit_code, :amount, :description)
  end
end
