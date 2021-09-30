// fadein
$(document).on('turbolinks:load', function() {
  $(window).scroll(function (){
    $('.fade__off').each(function(){
      const imgPos = $(this).offset().top;
      const scroll = $(window).scrollTop();
      const windowHeight = $(window).height();
      if (scroll > imgPos - windowHeight + windowHeight/5){
        $(this).addClass("fade__on");
      } else {
        $(this).removeClass("fade__on");
      }
    });
  });
});