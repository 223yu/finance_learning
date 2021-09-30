$(document).on('turbolinks:load', function() {
  $(document).on('click', 'a[href^="/contents#"]', function(){
    const target_id = $(this).attr('href').substr(9,50);
    const target = $(target_id);
    const position = target.offset().top - 90;
    $('body,html').animate({scrollTop:position}, 1000, 'swing');
    return false;
  });
});