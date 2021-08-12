class CardEntriesController < ApplicationController
  before_action :select_start_month_to_end_month, only:[:index]

  def select
    @accounts = current_user.accounts_index_from_total_account('カード')
  end

end
