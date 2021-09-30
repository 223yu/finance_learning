// ドラッグで月選択を変更する
$(document).on('turbolinks:load', function() {
  // 変数定義
  let this_month = '';
  let prev_month = '';
  let start_month = '';

  let target = ['.select-month__label', '.select-month__label--second'];
  target.forEach(function(target){
    // 開始月クリック時
    $(target).mousedown(function(){
      // 初期化
      reset();

      if($(this).attr('class') == 'select-month__label'){
        $(this).addClass('select-month__label--first');
        $(this).removeClass('select-month__label');
        // checkboxにcheckを入れる
        $(this).prev().prop('checked', true);
        // 保持している変数を更新
        prev_month = Number($(this).attr('for').substr(3,2));
        start_month = Number($(this).attr('for').substr(3,2));
      }
    });
    // ホバー時
    $(target).mousemove(function(){
      if($('.select-month__label--first').length == 1){
        if($(this).attr('class') == 'select-month__label'){
          $(this).addClass('select-month__label--between');
          $(this).removeClass('select-month__label');
          // 保持している変数を更新
          prev_month = Number($(this).attr('for').substr(3,2));
        }
      }
      // 月未選択の状態で、月選択の範囲からマウスが出た場合リセット
      $('.select-month__boxes').mouseleave(function(){
        if($('.select-month__label--second').length == 0){
          // 初期化
          reset();
        }
      });
      // ホバー状態で逆方向にマウスを動かした時
      this_month = Number($(this).attr('for').substr(3,2));
      if((start_month <= this_month && this_month < prev_month) || (prev_month < this_month && this_month <= start_month)){
        $(`[for="mon${prev_month}"]`).addClass('select-month__label');
        $(`[for="mon${prev_month}"]`).removeClass('select-month__label--between');
        prev_month = this_month;
      }
    });

    // 終了月クリック解除時
    $(target).mouseup(function(){
      $('.select-month__label--first').addClass('select-month__label--second');
      $('.select-month__label--first').removeClass('select-month__label--first');
      $('.select-month__label--between').addClass('select-month__label--second');
      $('.select-month__label--between').removeClass('select-month__label--between');
      // checkboxにcheckを入れる
      if($(this).prev().prop('checked') == true){
        this_month = Number($(this).attr('for').substr(3,2));
        $(this).prev().prop('checked', false);
      }else{
        $(this).prev().prop('checked', true);
      }
    });
  });


  // function集
  // リセット
  function reset(){
    $('.select-month__checkbox').prop('checked', false);
    $('.select-month__label--first').addClass('select-month__label');
    $('.select-month__label--first').removeClass('select-month__label--first');
    $('.select-month__label--second').addClass('select-month__label');
    $('.select-month__label--second').removeClass('select-month__label--second');
    $('.select-month__label--between').addClass('select-month__label');
    $('.select-month__label--between').removeClass('select-month__label--between');
    prev_month = '';
    start_month = '';
  }
});