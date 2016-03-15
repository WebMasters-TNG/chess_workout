// Equivalent to $(document).ready:
$(function() {
  initPage();
});
$(window).bind('page:change', function() {
  initPage();
  $("#reverse_view").on("click", function() {
    // Reverse board columns
    $("tr").each(function(elem, index) {
      var arr_cols = $.makeArray($("td", this).detach());
      arr_cols.reverse();
      $(this).append(arr_cols);
    });
    // Reverse board rows
    $("tbody").each(function(elem, index) {
      var arr_rows = $.makeArray($("tr", this).detach());
      arr_rows.reverse();
      $(this).append(arr_rows);
    });
  });
  // setInterval(function(){
  //   window.location.reload();
  // }, 5000)
});

function initPage() {
  "use strict";

  $.ajaxSetup({
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  });

  var top_z = 100;
  var start_sq = 99;
  var pieceColor = '';

// Check which color the current user is playing as:
  if (userID == whiteID && userID == blackID) {
    pieceColor = 'piece'
  } else if (userID == whiteID) {
    pieceColor = 'white_piece'
  }
  else {
    pieceColor = 'black_piece'
  };

  $('.' + pieceColor).draggable({
    cursor: "pointer",
    containment: ".board",
    snap: ".board td",
    snapTolerance: 20,
    revert: "invalid",
    // As soon as the user starts dragging, trigger this function:
    start: function() {
      // Initial piece position:
      $(this).data("oldPosition", $(this).offset());
      start_sq = this.closest("td").id;
    }
  }).on("mousedown", function() {
    // Make the moving piece the top layer on the view, because the DOM elements are rendered in chronological order.
    this.style.zIndex = ++top_z;
  });

// Where do you allow the dragged pieces to be dropped at?  Only within the squares of the chess board:
  $(".board td").droppable({
    accept: ".piece",
    tolerance: "fit",
    drop: handleDrop
  });

  // Animates reversion of piece to original location when a move is invalid:
  function revertAnimate(ui, oldPosition, speed){
    var newPosition = ui.draggable.offset();
    var leftOffset = null;
    var topOffset = null;
    if (oldPosition.left > newPosition.left) {
      leftOffset = (oldPosition.left - newPosition.left);
    } else {
      leftOffset = -(newPosition.left - oldPosition.left);
    }
    if (oldPosition.top > newPosition.top) {
      topOffset = (oldPosition.top - newPosition.top);
    } else {
      topOffset = -(newPosition.top - oldPosition.top);
    }
    ui.draggable.animate({
      left: '+=' + leftOffset,
      top: '+=' + topOffset,
    }, speed)
  };

// The drop event, which is called upon mouse release.  The ui is the item that is receiving?
  function handleDrop(event, ui) {
    // If the starting square is the same as the destination square, skip all this logic and do nothing:
    if (this.id != start_sq) {
      $.ajax({
        // "this" is the current active DOM element.
        context: this,
        type: 'PUT',
        // The AJAX request will be received by the 'piece-url', which can then be accessed in the Pieces Controller:
        url: ui.draggable.data('piece-url'), // Mike suggested we pass the piece as data below instead, but that is optional
        dataType: 'json',
        // this.id is the destination square
        data: { piece: {x_position: Number(this.id.charAt(1)), y_position: Number(this.id.charAt(0))} },
        error: function(){
          var oldPosition = ui.draggable.data().oldPosition;
          revertAnimate(ui, oldPosition, 'fast');
          return;
        },
        success: function(){
          $(".board td").removeClass("moved_sq");
          // Check for piece overlap, and therefore capture:
          if ($(this).find(".piece").hasClass("white_piece")) {
            $(this).find(".piece").appendTo("#white_captured");
          } else {
            $(this).find(".piece").appendTo("#dark_captured");
          }
          // Must empty any piece that was originally in the square (the captured piece):
          $(this).empty();
          // Adjusts the position of the piece, so its displayed position matches its already updated position in the database:
          ui.draggable.draggable("option", "revert", false);
          var oldPosition = ui.draggable.offset();
          $(ui.draggable).appendTo(this);
          revertAnimate(ui, oldPosition, 0);
          ui.draggable.draggable("option", "revert", "invalid");
          $("#" + start_sq).addClass("moved_sq");
          $(this).addClass("moved_sq");
          $("#moves").prepend("<li>" + ui.draggable.attr("id") + ": " + start_sq + " --> " + this.id + "</li>");
        }
      })
    } else {
      return;
    }
  };


  // function promotion(new_x, new_y) {
  //   var targetPiece = $('td#' + new_y + new_x).find(".piece");
  //   if (new_y == 1 && targetPiece.is("#white-pawn")) {
  //     targetPiece.empty();
  //     targetPiece.append(white_promotion);
  //     targetPiece.attr("id", "#white-queen");
  //   } else if (new_y == 8 && targetPiece.is("#black-pawn")) {
  //     targetPiece.empty();
  //     targetPiece.append(black_promotion);
  //     targetPiece.attr("id", "#black-queen");
  //   };
  // };
}

Game = {  
  // Long polling function to check for new moves
  poll: function() {
    $.ajax({ 
      type: 'GET',
      dataType: 'json',
      url: game,
      data: {"game_id": game_id, "move_id": last_move},
      success: function (data) {
        console.log(data['new_move']);
        var lastServerMove = data['new_move'];
        $(".board td").removeClass("moved_sq");
        if (lastServerMove != null && lastServerMove.length > 0) {
          lastServerMove.forEach(function(move) {
            if (move['id'] > last_move) {
              if (move['captured_piece'] == true) {
                if ($('td#' + move['old_y'] + move['old_x']).find(".piece").hasClass("white_piece") && data['turn'] % 2 != 0) {
                  $('td#' + move['old_y'] + move['old_x']).find(".piece").appendTo("#white_captured");
                } else if ($('td#' + move['old_y'] + move['old_x']).find(".piece").hasClass("black_piece") && data['turn'] % 2 == 0) {
                  $('td#' + move['old_y'] + move['old_x']).find(".piece").appendTo("#dark_captured");
                };
              } else {
                $('td#' + move['old_y'] + move['old_x']).find('.piece').appendTo('td#' + move['new_y'] + move['new_x']);
                // Game.promotion;
                var targetPiece = $('td#' + move['new_y'] + move['new_x']).find(".piece");
                if (move['new_y'] == 1 && targetPiece.is("#white-Pawn")) {
                  targetPiece.empty().append('<img src="/assets/White Queen.svg" class="piece_image">');
                  targetPiece.attr("id", "#white-Queen");
                } else if (move['new_y'] == 8 && targetPiece.is("#black-Pawn")) {
                  targetPiece.empty().append('<img src="/assets/Black Queen.svg" class="piece_image">');
                  targetPiece.attr("id", "#black-Queen");
                };
              };
              last_move = move['id'];
            };
          });
          $('.game_turn').html(data['turn']);
        } else {
          console.log("No new moves");
        };
      },
      error: function() {
        console.log("No update available");
      }
    });
    setTimeout(Game.poll, 5000);
  },

  // Check to see if pawn promotion and update piece image accordingly
  // promotion: function() {
  //   var targetPiece = $('td#' + move['new_y'] + move['new_x']).find(".piece");
  //   if (new_y == 1 && targetPiece.is("#white-pawn")) {
  //     targetPiece.empty();
  //     targetPiece.append("White Queen");
  //     targetPiece.attr("id", "#white-queen");
  //   } else if (new_y == 8 && targetPiece.is("#black-pawn")) {
  //     targetPiece.empty();
  //     targetPiece.append("Black Queen");
  //     targetPiece.attr("id", "#black-queen");
  //   };
  // }
}



