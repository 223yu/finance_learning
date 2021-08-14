class TransitionTablesController < ApplicationController
  before_action :select_start_month_to_end_month, only:[:index]

  def select
  end

  def index
    @accounts = Account.where(user_id: current_user.id, year: current_user.year)
  end

end
