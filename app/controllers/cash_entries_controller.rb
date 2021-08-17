class CashEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :select_start_month_to_end_month, only:[:index]
  after_action :discard_flash_if_xhr

  def select
    @accounts = current_user.accounts_index_from_total_account('現預金')
  end

  def index
    @self_code = params[:self_code]
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
      range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
      @journals = current_user.journal_index_from_self_code(@self_code, range, 0)
      @journal = Journal.new
    end
  end

  def create
    @journal = Journal.new(journal_params)
    if @journal.arrange_and_save_in_simple_entry(current_user)
      # 作成後の仕訳について残高更新処理
      update_debit_and_credit_balance(@journal.date.month, @journal.debit_id, @journal.credit_id, @journal.amount)
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
    # 更新前の仕訳情報を取得しておく
    prev_date = @journal.date
    prev_debit_id = @journal.debit_id
    prev_credit_id = @journal.credit_id
    prev_amount = @journal.amount
    prev_description = @journal.description
    # 更新 update時descriptionのみDB更新される
    @journal.update(journal_params)
    @self_code = @journal.self_code
    @self_id = current_user.code_id(@self_code)
    if @journal.arrange_and_save_in_simple_entry(current_user)
      # 更新前の仕訳について残高戻し処理
      update_debit_and_credit_balance(prev_date.month, prev_debit_id, prev_credit_id, - prev_amount)
      # 更新後の仕訳について残高更新処理
      update_debit_and_credit_balance(@journal.date.month, @journal.debit_id, @journal.credit_id, @journal.amount)
    else
      # 更新に失敗した場合は更新前に戻す
      flash[:danger] = '入力が正しくない項目があります'
      @journal.update(date: prev_date, debit_id: prev_debit_id, credit_id: prev_credit_id, amount: prev_amount, description: prev_description)
      @journal.arrange_for_display_in_simple_entry(@self_id)
    end
  end

  def destroy
    journal = Journal.find(params[:id])
    @id = journal.id
    journal.delete_after_updating_balance
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

    respond_to do |format|
      format.html
      format.json
    end
  end

  private

    def journal_params
      params.require(:journal).permit(:month, :day, :self_code, :nonself_code, :received_amount, :invest_amount, :description)
    end

end
