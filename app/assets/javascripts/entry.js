//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery
//= require jquery_ujs

// 勘定科目を入力すると科目名を補完する
$(document).on('turbolinks:load', function() {
  // 借方科目
  $(document).on('keyup', '#journal_debit_code', function(){
    $('#journal_debit_name').val(''); //一度削除
    $('.entry__subbox').html(''); //候補を空に
    const code = $(this).val();
    search(code, '#journal_debit_name');
    search_sub(code);
  });

  // 貸方科目
  $(document).on('keyup', '#journal_credit_code', function(){
    $('#journal_credit_name').val(''); //一度削除
    $('.entry__subbox').html(''); //候補を空に
    const code = $(this).val();
    search(code, '#journal_credit_name');
    search_sub(code);
  });

  // ①コードから科目を入力する
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

  //②コードから科目候補を表示する
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