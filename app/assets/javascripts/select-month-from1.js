// ドラッグで月選択を変更する
$(document).on('turbolinks:load', function() {
  // 変数定義
  let this_month = '';
  let prev_month = '';

  // 開始月クリック時
  $('.select-month-from1__label').mousedown(function(){
    // 初期化
    reset();

    if($(this).attr('class') == 'select-month-from1__label'){
      // 保持している変数を更新
      prev_month = Number($(this).attr('for').substr(3,2));
      // 当月のクラスを変更する
      $(this).addClass('select-month-from1__label--first');
      $(this).removeClass('select-month-from1__label');
      $(this).prev().prop('checked', true);
      // 前月までを全て着色
      for(let mon=2;mon<prev_month;mon++){
        $(`[for="mon${mon}"]`).addClass('select-month-from1__label--between');
        $(`[for="mon${mon}"]`).removeClass('select-month-from1__label');
      }
    }
  });

  // ホバー時
  $('.select-month-from1__label').mousemove(function(){
    if($('.select-month-from1__label--first').length == 1){
      if($(this).attr('class') == 'select-month-from1__label'){
        $('.select-month-from1__label--first').addClass('select-month-from1__label--between');
        $('.select-month-from1__label--first').removeClass('select-month-from1__label--first');
        $(this).addClass('select-month-from1__label--first');
        $(this).removeClass('select-month-from1__label');
        // checkboxを更新
        $('.select-month-from1__checkbox').prop('checked', false);
        // 保持している変数を更新
        prev_month = Number($(this).attr('for').substr(3,2));
      }

      // ホバー状態で逆方向にマウスを動かした時
      this_month = Number($(this).attr('for').substr(3,2));
      if(this_month < prev_month){
        $(`[for="mon${prev_month}"]`).addClass('select-month-from1__label');
        $(`[for="mon${prev_month}"]`).removeClass('select-month-from1__label--first');
        $(this).addClass('select-month-from1__label--first');
        $(this).removeClass('select-month-from1__label--between');
        prev_month = this_month;
      }
    }
  });

  // mouseup前に、月選択の範囲からマウスが出た場合リセット
  $('.select-month-from1__boxes').mouseleave(function(){
    let check_count = 0;
    for(let mon=2;mon<13;mon++){
      if($(`[id="mon${mon}"]`).prop('checked') == true){
        check_count ++;
      }
    }

    if(check_count == 0){
      // 初期化
      reset();
    }
  });

  // 終了月クリック解除時
  $('.select-month-from1__label').mouseup(function(){
    $('.select-month-from1__label--first').addClass('select-month-from1__label--second');
    $('.select-month-from1__label--first').removeClass('select-month-from1__label--first');
    $('.select-month-from1__label--between').addClass('select-month-from1__label--second');
    $('.select-month-from1__label--between').removeClass('select-month-from1__label--between');
    // checkboxにcheckを入れる
    this_month = Number($(this).attr('for').substr(3,2));
    if($(this).prev().prop('checked') == true){
      $(this).prev().prop('checked', false);
    }else{
      $(this).prev().prop('checked', true);
    }
  });

  // function集
  // リセット
  function reset(){
    $('.select-month-from1__checkbox').prop('checked', false);
    $('.select-month-from1__label--first').addClass('select-month-from1__label');
    $('.select-month-from1__label--first').removeClass('select-month-from1__label--first');
    $('.select-month-from1__label--second').addClass('select-month-from1__label');
    $('.select-month-from1__label--second').removeClass('select-month-from1__label--second');
    $('.select-month-from1__label--between').addClass('select-month-from1__label');
    $('.select-month-from1__label--between').removeClass('select-month-from1__label--between');
    prev_month = '';
  }
});