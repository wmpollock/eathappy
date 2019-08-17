var rotation = 0;

$(document).ready(function() {

//  $("#sourceImage").parent().zoom({'magnify': 2});

  $('a.rotate').click(function() {
    var offset = $(this).data('rotate'),
        $imgs =     $("#sourceImage,.zoomImg")
    if (offset) {
      rotation += offset;
    }

    if (rotation >= 360) {
      rotation -= 360;
    } else if (rotation < 0) {
      rotation += 360;
    }

    if (rotation == 90) {
      $imgs.css('margin-left', '10em');
    } else {
      $imgs.css('margin-left', '0em');
    }
// Nocanhas stack?!?
//    $("#sourceImage,.zoomImg").rotate(rotation);
//    $("#sourceImage").rotate(rotation);
//    $(".zoomImg").rotate(rotation);
//    console.log("OFFSET: " + offset);
    $imgs.rotate(rotation);

    console.log("Rotation: " + rotation);
    
  });

});

