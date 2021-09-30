$(document).on('turbolinks:load', function() {
  $(document).on('click', '.modal__open-btn', function(){
    $('.modal__area').fadeIn();
    $('.modal__close-btn').fadeIn();
    $('.modal__open-btn').fadeOut();
    return false;
  });
  const target = ['.modal__close-btn', '.modal__background'];
  target.forEach(function(target){
    $(document).on('click', target, function(){
      $('.modal__area').fadeOut();
      $('.modal__close-btn').fadeOut();
      $('.modal__open-btn').fadeIn();
      return false;
    });
  });
});