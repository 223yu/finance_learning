class SingleEntriesController < ApplicationController
  before_action :select_start_month_to_end_month, only:[:index]

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
      @journals = Journal.where(user_id: current_user.id, date: range)
      @journals = @journals.where(debit_id: current_user.code_id(params[:debit_code].to_i)) unless params[:debit_code] == ''
      @journals = @journals.where(credit_id: current_user.code_id(params[:credit_code].to_i)) unless params[:credit_code] == ''
      @journals = @journals.where(amount: params[:amount]) unless params[:amount] == ''
      @journals = @journals.where('description LIKE ?', "%#{params[:description]}%") unless params[:description] == ''

      @journal = Journal.new
    else
    # nomal mode
      range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
      @journals = Journal.where(user_id: current_user.id, date: range)
      @journal = Journal.new
    end
  end

  def create
    @journal = Journal.new(journal_params)
    @journal.arrange_and_save(current_user)
    @journal_new = Journal.new
  end

  def edit
    @journal = Journal.find(params[:id])
    @journal.arrange_for_display
  end

  def update
    @journal = Journal.find(params[:id])
    @journal.update(journal_params)
    @journal.arrange_and_save(current_user)
  end

  def destroy
    journal = Journal.find(params[:id])
    @id = journal.id
    journal.delete_after_updating_balance
  end

  def search
    @start_month = params[:start_month]
    @end_month = params[:end_month]
    @activated = params[:activated]
    @journal = Journal.new
  end

  private

    def journal_params
      params.require(:journal).permit(:month, :day, :debit_code, :credit_code, :amount, :description)
    end

end
