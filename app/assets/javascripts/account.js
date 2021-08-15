// 合計科目が損益科目の場合期首残高の数字を0、読取専用にする
$(document).on('turbolinks:load', function() {
  const PROFIT_AND_LOSS_STATEMENT = ['収入', '原価', '販管費', '営業外収入', '営業外費用'];
  // 合計科目を変更した場合
  $(document).on('change', '#account_total_account', function(){
    if(PROFIT_AND_LOSS_STATEMENT.includes($(this).val())){
      $(this).parent('td').prev().children('input').val(0);
      $(this).parent('td').prev().children('input').prop('readonly', true);
      $(this).parent('div').prev().children('input').val(0);
      $(this).parent('div').prev().children('input').prop('readonly', true);
    }else{
      $(this).parent('td').prev().children('input').prop('readonly', false);
      $(this).parent('div').prev().children('input').prop('readonly', false);
    }
  });

  // create失敗時のrender(update失敗時はviewで対応)
  const target = $('#account_total_account')
  if(PROFIT_AND_LOSS_STATEMENT.includes($(target).val())){
    $(target).parent('td').prev().children('input').val(0);
    $(target).parent('td').prev().children('input').prop('readonly', true);
  }
});


// Enterキーでタブ移動出来るようにする
$(document).on('turbolinks:load', function() {

  const target = ['#account_name', '#account_code', '#account_opening_balance_1', '#account_total_account'];
  target.forEach(function(target){
    $(document).on('keydown', target, function(){
      enter_change_tab();
    });
  });

  // function集
  function enter_change_tab(){
    const elements = 'input[type=text]';
    $(elements).keypress(function(e){
      const c = e.which ? e.which : e.keyCode;
      if(c == 13){
        let index = $(this).attr('tabindex');
        index = String(Number(index) + 1);
        $('[tabindex=' + index + ']').focus();
        e.preventDefault(); //Enter送信無効
      }
    });
  }
});