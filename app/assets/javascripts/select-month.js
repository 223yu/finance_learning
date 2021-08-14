// 月選択の見た目を整える
$(document).on('turbolinks:load', function() {
  let select_count = 0;
  let select_first_month = 0;
  let select_second_month = 0;

  if($('.select-month__label--first-only').length == 1){
    select_count = 1;
    select_first_month = 1;
  }

  // 2月目選択後の処理を関数化
  function after_select_second_month(e){
    // class書き換え
    $(e).addClass('select-month__label--second');
    $(e).removeClass('select-month__label');
    // 2月目を取得
    select_second_month = $(e).attr('for').substr(3,2);
    // 1月目と2月目の間の月のclass書き換え
    let between_count = Math.abs(Number(select_first_month) - Number(select_second_month));
    let min_count = Math.min(Number(select_first_month), Number(select_second_month));
    let between_array = [...Array(between_count -1 )].map((_, i) => 'mon' + String(i + min_count + 1));
    let mon_array = [...Array(12)].map((_, i) => '#month' + String(i + 1));
    between_array.forEach(function(between){
      mon_array.forEach(function(mon){
        if($(mon).attr('for') == between){
          $(mon).addClass('select-month__label--between');
          $(mon).removeClass('select-month__label');
        }
      });
    });
  }

  $('.select-month__label').on('click', function(){

    if(select_count == 2){
      if($(this).attr('class') == 'select-month__label--second'){
        $(this).addClass('select-month__label');
        $(this).removeClass('select-month__label--second');
        $('.select-month__label--between').addClass('select-month__label');
        $('.select-month__label--between').removeClass('select-month__label--between');
        select_count -= 1;
      }else if($('.select-month__label--first-only').length == 1){
        let month_id = "#mon" + String(select_second_month);
        // 2月目のチェックを外す
        $(month_id).removeAttr('checked').prop('checked', false).change();
        // クラス書き換え
        $('.select-month__label--second').addClass('select-month__label')
        $('.select-month__label--second').removeClass('select-month__label--second')
        $('.select-month__label--between').addClass('select-month__label');
        $('.select-month__label--between').removeClass('select-month__label--between');
        after_select_second_month(this);
      }else{
        let month_id = "#mon" + String(select_first_month);
        select_first_month = select_second_month;
        // 1月目のチェックを外す
        $(month_id).removeAttr('checked').prop('checked', false).change();
        // クラス書き換え
        $('.select-month__label--first').addClass('select-month__label');
        $('.select-month__label--first').removeClass('select-month__label--first');
        $('.select-month__label--second').addClass('select-month__label--first');
        $('.select-month__label--second').removeClass('select-month__label--second');
        $('.select-month__label--between').addClass('select-month__label');
        $('.select-month__label--between').removeClass('select-month__label--between');
        after_select_second_month(this);
      }
    }else if(select_count == 1){
      if($(this).attr('class') == 'select-month__label--first'){
        $(this).addClass('select-month__label');
        $(this).removeClass('select-month__label--first');
        select_count -= 1;
      }else if($(this).attr('class') == 'select-month__label--first-only'){
        // 特に何も行わない
      }else{
        after_select_second_month(this);
        select_count += 1;
      }
    }else if(select_count == 0){
      $(this).addClass('select-month__label--first');
      $(this).removeClass('select-month__label');
      select_first_month = $(this).attr('for').substr(3,2);
      select_count += 1;
    }
  });
});