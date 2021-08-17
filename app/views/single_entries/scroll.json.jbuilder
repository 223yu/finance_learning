if @journals
  json.array! @journals do |journal|
    json.id journal.id
    json.month journal.month
    json.day journal.day
    json.debit_code journal.debit_code
    json.debit_name journal.debit_name
    json.credit_code journal.credit_code
    json.credit_name journal.credit_name
    json.amount journal.amount
    json.description journal.description
  end
end