$(document).on('turbolinks:load', function () {
  $('.link').on('click', function () {
    const location = $(this).data('href');
    if (location) {
      Turbolinks.visit(location);
      return false
    }
  })
});
