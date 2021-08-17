if @journals
  json.array! @journals do |journal|
    json.self_code @self_code
    json.id journal.id
    json.month journal.month
    json.day journal.day
    json.nonself_code journal.nonself_code
    json.nonself_name journal.nonself_name
    if journal.received_amount == nil
      json.received_amount 0
    else
      json.received_amount journal.received_amount
    end
    if journal.invest_amount == nil
      json.invest_amount 0
    else
      json.invest_amount journal.invest_amount
    end
    json.description journal.description
  end
end