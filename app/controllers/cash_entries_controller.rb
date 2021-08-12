class CashEntriesController < ApplicationController
  before_action :select_start_month_to_end_month, only:[:index]

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
      @journals = current_user.journal_index_from_self_code(@self_code, range)
      unless params[:nonself_code] == ''
        nonself_id = current_user.code_id(params[:nonself_code].to_i)
        @journals = @journals.where(debit_id: nonself_id).or(@journals.where(credit_id: nonself_id))
      end
      @journals = @journals.where(debit_id: @self_id, amount: params[:received_amount].to_i) unless params[:received_amount] == ''
      @journals = @journals.where(credit_id: @self_id, amount: params[:invest_amount].to_i) unless params[:invest_amount] == ''
      @journals = @journals.where('description LIKE ?', "%#{params[:description]}%") unless params[:description] == ''
      @journals = @journals.order(:date)

      @journal = Journal.new
    else
    # nomal mode
      range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
      @journals = current_user.journal_index_from_self_code(@self_code, range)
      @journals = @journals.order(:date)
      @journal = Journal.new
    end
  end

  def create
    @journal = Journal.new(journal_params)
    @journal.arrange_and_save_in_simple_entry(current_user)
    @self_code = @journal.self_code
    @self_id = current_user.code_id(@self_code)
    @journal_new = Journal.new
  end

  def edit
    @self_code = params[:self_code]
    @self_id = current_user.code_id(@self_code)
    @journal = Journal.find(params[:id])
    @journal.arrange_for_display_in_simple_entry(@self_id)
  end

  def update
    @journal = Journal.find(params[:id])
    @journal.update(journal_params)
    @journal.arrange_and_save_in_simple_entry(current_user)
    @self_code = @journal.self_code
    @self_id = current_user.code_id(@self_code)
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

  private

    def journal_params
      params.require(:journal).permit(:month, :day, :self_code, :nonself_code, :received_amount, :invest_amount, :description)
    end

end
