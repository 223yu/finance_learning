class CashEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :select_start_month_to_end_month, only: [:index]
  after_action :discard_flash_if_xhr

  def select
    @accounts = current_user.accounts_index_from_total_account('現預金')
  end

  def index
    @self_code = params[:self_code]
    if @self_code == ''
      flash[:danger] = '表示する月を選択してください。'
      respond_to do |format|
        format.js { render ajax_redirect_to(request.referer) }
      end
    else
      @self_id = current_user.code_id(@self_code)
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
        @journals = current_user.journal_index_from_self_code(@self_code, range, 0)
        unless params[:nonself_code] == ''
          nonself_id = current_user.code_id(params[:nonself_code].to_i)
          @journals = @journals.where(debit_id: nonself_id).or(@journals.where(credit_id: nonself_id))
        end
        @journals = @journals.where(debit_id: @self_id, amount: params[:received_amount].to_i) unless params[:received_amount] == ''
        @journals = @journals.where(credit_id: @self_id, amount: params[:invest_amount].to_i) unless params[:invest_amount] == ''
        @journals = @journals.where('description LIKE ?', "%#{params[:description]}%") unless params[:description] == ''

        @journal = Journal.new
      else
        # nomal mode
        if @get_start_month == 0
          flash[:danger] = '表示する月を選択してください。'
          respond_to do |format|
            format.js { render ajax_redirect_to(request.referer) }
          end
        else
          range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
          @journals = current_user.journal_index_from_self_code(@self_code, range, 0)
          @journal = Journal.new
        end
      end
    end
  end

  def create
    @journal = Journal.new(journal_params)
    if @journal.self_create_and_update_account_balance_in_simple_entry(current_user)
      @journal_new = Journal.new
    else
      flash[:danger] = '入力が正しくない項目があります'
    end
    @self_code = @journal.self_code
    @self_id = current_user.code_id(@self_code)
  end

  def edit
    @self_code = params[:self_code]
    @self_id = current_user.code_id(@self_code)
    @journal = Journal.find(params[:id])
    @journal.arrange_for_display_in_simple_entry(@self_id)
  end

  def update
    @journal = Journal.find(params[:id])
    if @journal.self_update_and_update_account_balance_in_simple_entry(current_user, journal_params)
      @self_code = @journal.self_code
      @self_id = current_user.code_id(@self_code)
    else
      @self_code = @journal.self_code
      @self_id = current_user.code_id(@self_code)
      flash[:danger] = '入力が正しくない項目があります'
      @journal.arrange_for_display_in_simple_entry(@self_id)
    end
  end

  def destroy
    journal = Journal.find(params[:id])
    @id = journal.id
    unless journal.delete_after_updating_balance
      flash[:danger] = '仕訳の削除に失敗しました'
    end
  end

  def search
    @self_code = params[:self_code]
    @start_month = params[:start_month]
    @end_month = params[:end_month]
    @activated = params[:activated]
    @journal = Journal.new
  end

  def scroll
    @self_code = params[:self_code]
    self_id = current_user.code_id(@self_code)
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
    @journals = current_user.journal_index_from_self_code(@self_code, range, offset)
    # 検索ワードがあれば絞り込み
    unless params[:nonself_code] == ''
      nonself_id = current_user.code_id(params[:nonself_code].to_i)
      @journals = @journals.where(debit_id: nonself_id).or(@journals.where(credit_id: nonself_id))
    end
    @journals = @journals.where(debit_id: self_id, amount: params[:received_amount].to_i) unless params[:received_amount] == ''
    @journals = @journals.where(credit_id: self_id, amount: params[:invest_amount].to_i) unless params[:invest_amount] == ''
    @journals = @journals.where('description LIKE ?', "%#{params[:description]}%") unless params[:description] == ''

    @journals.each do |journal|
      journal.arrange_for_display_in_simple_entry(self_id)
    end
  end

  private

  def journal_params
    params.require(:journal).permit(:month, :day, :self_code, :nonself_code, :received_amount, :invest_amount, :description)
  end
end
