// 合計科目が損益科目の場合期首残高の数字を0、入力不可にする
$(document).on('turbolinks:load', function() {
  // 合計科目を変更した場合
  $(document).on('change', '#account_total_account', function(){
    let PROFIT_AND_LOSS_STATEMENT = ['収入', '原価', '販管費', '営業外収入', '営業外費用'];
    if(PROFIT_AND_LOSS_STATEMENT.includes($(this).val())){
      $(this).parent('td').prev().children('input').val(0);
      $(this).parent('td').prev().children('input').prop('disabled', true);
      $(this).parent('div').prev().children('input').val(0);
      $(this).parent('div').prev().children('input').prop('disabled', true);
    }else{
      $(this).parent('td').prev().children('input').prop('disabled', false);
      $(this).parent('div').prev().children('input').prop('disabled', false);
    }
  });
});