if @accounts
  json.array! @accounts do |account|
    json.code account.code
    json.name account.name
  end
end