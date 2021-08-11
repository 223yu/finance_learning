class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :year])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    end

  private
    def select_start_month_to_end_month
      @get_start_month = 0
      @get_end_month = 0
      get_months = []
      get_months.push(params[:mon1])
      get_months.push(params[:mon2])
      get_months.push(params[:mon3])
      get_months.push(params[:mon4])
      get_months.push(params[:mon5])
      get_months.push(params[:mon6])
      get_months.push(params[:mon7])
      get_months.push(params[:mon8])
      get_months.push(params[:mon9])
      get_months.push(params[:mon10])
      get_months.push(params[:mon11])
      get_months.push(params[:mon12])

      n = 1
      get_months.each do |get_month|
        if @get_start_month == 0 && get_month.to_i == 1
          @get_start_month = n
          n += 1
        elsif get_month.to_i == 1
          @get_end_month = n
          n += 1
        elsif @get_start_month != 0 && @get_end_month == 0
          @get_end_month = @get_start_month
          n += 1
        else
          n += 1
        end
      end
    end
end
