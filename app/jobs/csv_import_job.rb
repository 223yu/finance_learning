class CsvImportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(user_id)
    imports = Import.where(user_id: user_id, pending: true)
    imports.each do |import|
      import.create_journal_from_import
    end
  end
end
