$('.sidebar-nav').scrollspy();
$("#sidenav").height($(this).height() * 0.75);
$(window).resize(function () {
    $("#sidenav").height($(this).height() * 0.75);
});