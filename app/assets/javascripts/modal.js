$(document).on('turbolinks:load', function() {
  $(document).on('click', '.modal__open-btn', function(){
    $('.modal__area').fadeIn();
    $('.modal__open-btn').fadeOut();
    return false;
  });
  $(document).on('click', '.modal__close-btn', function(){
    $('.modal__area').fadeOut();
    $('.modal__open-btn').fadeIn();
    return false;
  });
});