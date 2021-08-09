class SingleEntriesController < ApplicationController
  before_action :select_start_month_to_end_month, only:[:index]

  def select
  end

  def index
    range = current_user.start_date_to_end_date(@get_start_month, @get_end_month)
    @journals = Journal.where(user_id: current_user.id, date: range)
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(journal_params)
    month = @journal.month.to_i
    day = @journal.day.to_i
    debit_id = Account.find_by(user_id: current_user.id, year: current_user.year, code: @journal.debit_code).id
    credit_id = Account.find_by(user_id: current_user.id, year: current_user.year, code: @journal.credit_code).id
    @journal.user_id = current_user.id
    @journal.date = Date.new(current_user.year, month, day)
    @journal.debit_id = debit_id
    @journal.credit_id = credit_id
    if @journal.save
      @journal_new = Journal.new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def journal_params
      params.require(:journal).permit(:month, :day, :debit_code, :credit_code, :amount, :description)
    end

end
