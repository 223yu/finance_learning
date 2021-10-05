class SingleEntryImportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @imports = Import.where(user_id: current_user.id, pending: false)
  end

  def create
    # csvファイルが読み込まれた場合のみ処理を行う
    if params[:file] && File.extname(params[:file].original_filename) == '.csv'
      result_hash = Import.create_import_from_csv(current_user, params[:file])
      flash[:success] = "#{result_hash[:success_count]}件の仕訳を取り込みました。"
      flash[:danger] = "#{result_hash[:error_rows]}、#{result_hash[:error_count]}件のエラーが発生しました。" if result_hash[:error_count] > 0
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
    Import.all_destroy(current_user)
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
