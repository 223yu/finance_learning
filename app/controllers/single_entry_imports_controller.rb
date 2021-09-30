class SingleEntryImportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @imports = Import.where(user_id: current_user.id, pending: false)
  end

  def create
    # csvファイルが読み込まれた場合のみ処理を行う
    if params[:file] && File.extname(params[:file].original_filename) == '.csv'
      # 変数定義
      n = 2 # 取込行
      success_count = 0 # 成功数
      error_count = 0 # 失敗数
      error_present = false
      flash[:danger] = ''
      # csv取込実行
      CSV.foreach(params[:file].path, headers: true) do |row|
        import = Import.new
        import.user_id = current_user.id
        if Date.valid_date?(row[0].to_i, row[1].to_i, row[2].to_i)
          if current_user.year == row[0].to_i
            import.date = Date.new(row[0].to_i, row[1].to_i, row[2].to_i)
          else
            error_present = true
          end
        else
          error_present = true
        end
        if Account.find_by(user_id: current_user.id, year: current_user.year, code: row[3].to_i).present?
          import.debit_id = current_user.code_id(row[3].to_i)
        else
          error_present = true
        end
        if Account.find_by(user_id: current_user.id, year: current_user.year, code: row[4].to_i).present?
          import.credit_id = current_user.code_id(row[4].to_i)
        else
          error_present = true
        end
        if row[5].to_i > 0
          import.amount = row[5].to_i
        else
          error_present = true
        end
        if row[6].nil?
          import.description = ''
        else
          import.description = row[6]
        end
        if error_present == true
          error_count += 1
          flash[:danger] << " #{n}行."
        elsif error_present == false
          if import.save
            success_count += 1
          end
        end
        n += 1
        error_present = false
      end
      flash[:success] = "#{success_count}件の仕訳を取り込みました。"
      if error_count > 0
        flash[:danger] << "以上、#{error_count}件のエラーが発生しました。"
      end
    else
      flash[:danger] = 'ファイルを読み込むことができませんでした。'
    end
    redirect_to single_entry_imports_path
  end

  def edit
    @import = Import.find(params[:id])
    @import.arrange_for_display
  end

  def update
    @import = Import.find(params[:id])
    unless @import.self_update(current_user, import_params)
      flash[:danger] = '入力が正しくない項目があります'
      @import.arrange_for_display
    end
  end

  def destroy
    import = Import.find(params[:id])
    @id = import.id
    unless import.destroy
      falsh[:danger] = '仕訳の削除に失敗しました'
    end
  end

  def import
    imports = Import.where(user_id: current_user.id, pending: false)
    # 取得した仕訳を待機中に変更
    imports.update_all(pending: true)
    CsvImportJob.perform_later(current_user.id)
    flash[:success] = '仕訳の取込を実行しています。しばらくしてから画面を再表示してください。'
    redirect_to single_entry_imports_path
  end

  def all_destroy
    imports = Import.where(user_id: current_user.id)
    imports.each do |import|
      import.destroy
    end
    flash[:success] = '取込待ち仕訳一覧の仕訳を全て削除しました。'
    redirect_to single_entry_imports_path
  end

  def download
    download_file_name = 'app/assets/csv/取込用csvファイル.csv'
    send_file download_file_name
  end

  private

  def import_params
    params.require(:import).permit(:month, :day, :debit_code, :credit_code, :amount, :description)
  end
end
