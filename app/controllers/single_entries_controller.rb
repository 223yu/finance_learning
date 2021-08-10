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

  private

    def journal_params
      params.require(:journal).permit(:month, :day, :debit_code, :credit_code, :amount, :description)
    end

end
