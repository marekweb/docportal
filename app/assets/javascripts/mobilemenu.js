$(document).ready(function() {
  
  $('.mobile-category').on('click', function(e) {
    $('.mobile-menu').toggleClass('open');
    $('.mobile-category').toggleClass('open');
    e.stopPropagation();
  });
  
  $('body').on('click', ':not(.mobile-menu)', function() {
    if ($('.mobile-menu').hasClass('open')) {
      $('.mobile-menu').removeClass('open');
      $('.mobile-category').removeClass('open');
    }
  });
  
});
