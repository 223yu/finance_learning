// 勘定科目を入力すると科目名を補完する
$(document).on('turbolinks:load', function() {
  // 借方コード、貸方コード
  let target = ['journal_debit', 'journal_credit', 'journal_nonself',
                'debit', 'credit', 'nonself',
                'import_debit', 'import_credit']; //4行目→nomal、5行目→search mode、6行目→csv import
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
            '#month', '#day', '#amount', '#received_amount', '#invest_amount',
            '#import_month', '#import_day', '#import_amount']; //24行目→nomal、25行目→search mode、26行目→csv import
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
                  '#month', '#day', '#debit_code', '#credit_code', '#amount', '#nonself_code', '#received_amount', 'invest_amount',
                  '#import_month', '#import_day', '#import_debit_code', '#import_credit_code', '#import_amount']; //83行目→nomal、84行目→search mode、85行目→csv import
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

// トップまでスクロールすることで追加の仕訳を取得する
$(document).on('turbolinks:load', function() {
  // 検索モード中に入力した値を保持しておく
  // 変数定義
  let month = '';
  let day = '';
  let debit_code = '';
  let credit_code = '';
  let amount = '';
  let description = '';

  // simple entry限定
  let self_code = '';
  let nonself_code = '';
  let received_amount = '';
  let invest_amount = '';

  $(document).on('input', '#month', function(){
    month = $('#month').val();
  });

  $(document).on('input', '#day', function(){
    day = $('#day').val();
  });

  $(document).on('input', '#debit_code', function(){
    debit_code = $('#debit_code').val();
  });

  $(document).on('input', '#credit_code', function(){
    credit_code = $('#credit_code').val();
  });

  $(document).on('input', '#amount', function(){
    amount = $('#amount').val();
  });

  $(document).on('input', '#description', function(){
    description = $('#description').val();
  });

  // simpe entry限定
  $(document).on('click', '.select-month__btn', function(){
    self_code = $('#self_code').val();
  });

  $(document).on('input', '#nonself_code', function(){
    nonself_code = $('#nonself_code').val();
  });

  $(document).on('input', '#received_amount', function(){
    received_amount = $('#received_amount').val();
  });

  $(document).on('input', '#invest_amount', function(){
    invest_amount = $('#invest_amount').val();
  });

  // targetに対して実行
  const target = $('.entry__index-tbody');
  target.scroll(function(){
    if (target.scrollTop() == 0){
      let start_month = $('.search-mode__form-start').val();
      let end_month = $('.search-mode__form-end').val();
      let offset = target.children().length;
      console.log(offset);
      // 単一入力(true)か簡易入力(false)かで分岐
      if($('#self_code').length == 0){
        //検索モード中に実行する場合は保持している(prevがつく)パラメータを利用し実行
        if($('.search-mode__form-activated').val() == 'true'){
          // 関数実行
          add_journal(target, offset, start_month, end_month,
          prev_month, prev_day, prev_debit_code, prev_credit_code, prev_amount, prev_description);
        }else{
          // 関数実行
          add_journal(target, offset, start_month, end_month,
            month, day, debit_code, credit_code, amount, description);
        }
      }else{
        //検索モード中に実行する場合は保持している(prevがつく)パラメータを利用し実行
        if($('.search-mode__form-activated').val() == 'true'){
          // 関数実行
          add_journal_in_simple_entry(target, offset, start_month, end_month,
          prev_month, prev_day, self_code, prev_nonself_code, prev_received_amount,
          prev_invest_amount, prev_description);
        }else{
          // 関数実行
          add_journal_in_simple_entry(target, offset, start_month, end_month,
          month, day, self_code, nonself_code, received_amount, invest_amount, description);
        }
      }
    }
  });

  // 検索モードを押した場合、検索ワードをリセットし、検索モードをキャンセルした場合には検索ワードを戻す
  let prev_month = '';
  let prev_day = '';
  let prev_debit_code = '';
  let prev_credit_code = '';
  let prev_amount = '';
  let prev_description = '';

  // sinple entry限定
  let prev_nonself_code = '';
  let prev_received_amount = '';
  let prev_invest_amount = '';

  $(document).on('click', '.search-mode__form-btn', function(){
    if($('.search-mode__form-activated').val() == 'false'){
      // 検索ワードを保持
      prev_month = month;
      prev_day= day;
      prev_debit_code = debit_code;
      prev_credit_code = credit_code;
      prev_amount = amount;
      prev_description = description;

      prev_nonself_code = nonself_code;
      prev_received_amount = received_amount;
      prev_invest_amount = invest_amount;
      // 検索ワードをリセット
      month = '';
      day = '';
      debit_code = '';
      credit_code = '';
      amount = '';
      description = '';

      nonself_code = '';
      received_amount = '';
      invest_amount = '';
    }else if($('.search-mode__form-activated').val() == 'true'){
      // 検索ワードを戻す
      month = prev_month;
      day = prev_day;
      debit_code = prev_debit_code;
      credit_code = prev_credit_code;
      amount = prev_amount;
      description = prev_description;

      nonself_code = prev_nonself_code;
      received_amount = prev_received_amount;
      invest_amount = prev_invest_amount;
      // 保持していた検索ワードをリセット
      prev_month = '';
      prev_day= '';
      prev_debit_code = '';
      prev_credit_code = '';
      prev_amount = '';
      prev_description = '';

      prev_nonself_code = '';
      prev_received_amount = '';
      prev_invest_amount = '';
    }
  });

  // 「表示」ボタンを押した時、検索ワードをリセットする
  $(document).on('click', '.select-month__btn', function(){
    month = '';
    day = '';
    debit_code = '';
    credit_code = '';
    amount = '';
    description = '';

    nonself_code = '';
    received_amount = '';
    invest_amount = '';
  });

  // function集
  //追加の仕訳を表示する
  function built_html(data, target){
    const html = `
      <div class='entry__index-tr${data.id}'>
        <div class='entry__index-td--date'>${data.month}</div>
        <div class='entry__index-td--date'>${data.day}</div>
        <div class='entry__index-td--code'>${data.debit_code}</div>
        <div class='entry__index-td--name'>${data.debit_name}</div>
        <div class='entry__index-td--code'>${data.credit_code}</div>
        <div class='entry__index-td--name'>${data.credit_name}</div>
        <div class='entry__index-td--amount'>${data.amount.toLocaleString()}</div>
        <div class='entry__index-td--description'>${data.description}</div>
        <div class='entry__index-td--btn'>
          <a class='entry__index-link' data-remote='true' href='/single_entries/${data.id}/edit'>
            <i class='fas fa-edit' aria-hidden='true'></i>
          </a>
        </div>
        <div class='entry__index-td--btn'>
          <a class='entry__index-link' data-remote='true' rel='nofollow' data-method='delete' href='/single_entries/${data.id}'>
            <i class='fas fa-trash-alt' aria-hidden='true'></i>
          </a>
        </div>
      </div>
    `;
    target.prepend(html);
  }

  // ajax通信を行い追加の仕訳を取得する
  function add_journal(target, offset, start_month, end_month,
          month, day, debit_code, credit_code, amount, description){
    $.ajax({
      type: 'GET',
      url: '/single_entries/scroll',
      data:{
        offset: offset, start_month: start_month, end_month: end_month,
        month: month, day: day, debit_code: debit_code, credit_code: credit_code,
        amount: amount, description: description
      },
      dataType: 'json'
    })
    .done(function(data){
      if(data.length != 0){
        data.forEach(function(data){
          built_html(data, target);
        });
        // scroll位置を調整
        $(target).scrollTop(data.length * 41);
      }
    });
  }

  //簡易入力において追加の仕訳を表示する
  function built_html_in_simple_entry(data, target){
    const html = `
      <div class='entry__index-tr${data.id}'>
        <div class='entry__index-td--date'>${data.month}</div>
        <div class='entry__index-td--date'>${data.day}</div>
        <div class='entry__index-td--nonself-code'>${data.nonself_code}</div>
        <div class='entry__index-td--name'>${data.nonself_name}</div>
        <div class='entry__index-td--amount'>${data.received_amount.toLocaleString()}</div>
        <div class='entry__index-td--amount'>${data.invest_amount.toLocaleString()}</div>
        <div class='entry__index-td--description'>${data.description}</div>
        <div class='entry__index-td--btn'>
          <a class='entry__index-link' data-remote='true' href='/cash_entries/${data.id}/edit?self_code=${data.self_code}'>
            <i class='fas fa-edit' aria-hidden='true'></i>
          </a>
        </div>
        <div class='entry__index-td--btn'>
          <a class='entry__index-link' data-remote='true' rel='nofollow' data-method='delete' href='/cash_entries/${data.id}'>
            <i class='fas fa-trash-alt' aria-hidden='true'></i>
          </a>
        </div>
      </div>
    `;
    target.prepend(html);
  }

  // 簡易入力においてajax通信を行い追加の仕訳を取得する
  function add_journal_in_simple_entry(target, offset, start_month, end_month,
          month, day, self_code, nonself_code, received_amount, invest_amount, description){
    $.ajax({
      type: 'GET',
      url: '/cash_entries/scroll',
      data:{
        offset: offset, start_month: start_month, end_month: end_month,
        month: month, day: day, self_code: self_code, nonself_code: nonself_code,
        received_amount: received_amount, invest_amount: invest_amount, description: description
      },
      dataType: 'json'
    })
    .done(function(data){
      if(data.length != 0){
        data.forEach(function(data){
          built_html_in_simple_entry(data, target);
        });
        // scroll位置を調整
        $(target).scrollTop(data.length * 41);
      }
    });
  }
});