// 勘定科目を入力すると科目名を補完する
$(document).on('turbolinks:load', function() {
  // 借方コード、貸方コード
  let target = ['journal_debit', 'journal_credit', 'journal_nonself',
                'debit', 'credit', 'nonself']; //4行目→nomal、5行目→search mode
  target.forEach(function(target){
    let target_code = '#' + target + '_code';
    let target_name = '#' + target + '_name';
    $(document).on('input', target_code, function(){
    $(target_name).val(''); //一度削除
    $('.entry__subbox').html(''); //候補を空に
    let code = $(this).val();
    // 全角の場合半角に変換
    code = double_to_half(code);
    $(this).val(code);
    // 実行
    search(code, target_name);
    search_sub(code);
    });
  });

  // その他の項目は全角を半角に変換するのみ
  target = ['#journal_month', '#journal_day', '#journal_amount', '#journal_received_amount', '#journal_invest_amount',
            '#month', '#day', '#amount', '#received_amount', '#invest_amount']; //23行目→nomal、24行目→search mode
  target.forEach(function(target){
    $(document).on('input', target, function(){
    let str = $(this).val();
    str = double_to_half(str);
    $(this).val(str);
    });
  });

  // function集
  // ①全角で入力されたコードを半角に変換する
  function double_to_half(str){
    str = str.replace( /[Ａ-Ｚａ-ｚ０-９－！”＃＄％＆’（）＝＜＞，．？＿［］｛｝＠＾～￥]/g, function(s) {
            return String.fromCharCode(s.charCodeAt(0) - 65248);
          });
    return str;
  }

  // ②コードから科目を入力する
  function search(keyword, target){
    $.ajax({
      type: 'GET',
      url: '/accounts/search',
      data: {code: keyword},
      dataType: 'json'
    })
    .done(function(data){
        $(target).val(data.name);
    });
  }

  //③コードから科目候補を表示する
  function built_html(data){
    let html = `
      <div class='entry__subbox-item'>${data.code} ${data.name}</div>
    `;
    $('.entry__subbox').append(html);
  }

  function search_sub(keyword){
    $.ajax({
      type: 'GET',
      url: '/accounts/search_sub',
      data:{code: keyword},
      dataType: 'json'
    })
    .done(function(data){
      data.forEach(function(data){
        built_html(data);
      });
    });
  }
});

// Enterキーでタブ移動出来るようにする
$(document).on('turbolinks:load', function() {

  const target = ['#journal_month', '#journal_day', '#journal_debit_code', '#journal_credit_code', '#journal_amount', '#journal_nonself_code', '#journal_received_amount', '#journal_invest_amount',
                  '#month', '#day', '#debit_code', '#credit_code', '#amount', '#nonself_code', '#received_amount', 'invest_amount']; //81行目→nomal、82行目→search mode
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
        // 摘要以外でのEnter送信無効
        if (index != '17'){
          e.preventDefault();
        }
      }
    });
  }
});

// 入金金額と出金金額に両方入力したら先に入力した方を削除する
$(document).on('turbolinks:load', function() {
  const target = [['#journal_received_amount', '#journal_invest_amount'], ['#journal_invest_amount', '#journal_received_amount'],
                  ['#received_amount', '#invest_amount'], ['#invest_amount', '#received_amount']]; ////109行目→nomal、110行目→search mode
  target.forEach(function(target){
    $(document).on('keydown', target[0], function(){
      if ($(target[0]).val() != '' && $(target[1]).val() != ''){
        $(target[1]).val('');
      }
    });
  });
});