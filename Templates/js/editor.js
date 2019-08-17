$(document).ready(function() {
  // EDITOR
  var $editor = $('.editor');

  if ($editor.length) {
    var $ingredients = $editor.find('.ingredients');

    // Trigger generation fo new ingredients
    var $ingredientItems = $editor.find(".ingredients .list-group-item"),
    $ingredientTemplate = $ingredientItems.first().clone(true); // need icons
    
    var $secondary_cat_checkbox = $editor.find('.secondary-categories input');

    $secondary_cat_checkbox.change(function(e) {
      $('.secondary-categories .count').text($secondary_cat_checkbox.filter(":checked").length);
    });
    
    if (formState) {
      $.each(formState, function(idx, val) {
	switch(idx) 
	{
	case "notes":
  	case "preparation":
	  $("textarea[name=" + idx + "]").val(val);
	  break;
	case "primary_category":
	  $("select[name=" + idx + '] option[value="' + val + '"]').attr('selected', 'selected');
	  break;
	default:
	  $("input[name=" + idx + "]").val(val);
	  break;	
	}
	
      });
      
      if (!formState.hasOwnProperty("untried")) {
	consola("UNTRIED");
	consola("UNCKECKNG");
	$('input[name="untried"]').prop('checked', false);
      }
      
      // Checkboxes
      if (formState.hasOwnProperty("secondary_categories")) {
	$.each(formState.secondary_categories, function(idx, val) {
	  $editor.find('.secondary-categories input[value="' + val + '"]').prop('checked', true).change();
	});
      }
	  consola("GONZAGA");
      
      // Ingredient insertion
//?? WTF THIS?? [BP -- 10 Mar 2016]
      if (formState.hasOwnProperty("ingredients")) {
	$.each(formState.ingredients, function(idx, ingredient) {
	  var $newIng = $ingredientTemplate.clone(true).insertBefore($ingredientItems.last());

	  /* TOdO:  align these values Name !~ PREP DESC [BP -- 15 Feb 2015] :( */
	  $newIng.find('input[name=measureQuant]').val(ingredient.quantity);
	  $newIng.find('input[name=ingredientName]').val(ingredient.ingredient_name);
	  $newIng.find('input[name=ingredientPrepName]').val(ingredient.ingredientPrepDesc);
	});
      }
    }
    
    // Trigger for /last element only
    $ingredients.on('change', '.form-group:last .edit input', function() {
//      $ingredientTemplate.clone(true).appendTo($ingredientItems);
      $ingredientTemplate.clone(true).appendTo($ingredients);
    });

    $ingredients.on('click', '.delete', function() {
      $(this).parents('li').remove();
    });

    $ingredients.sortable({axis: "y",
			   handle: ".sort"});

    $editor.find('input[type=submit].php-feed').click(function(e) {
      e.preventDefault();
      var $frm = $(this).parents("form");
      $.ajax({
	type: "POST",
	url: "/eathappy/php/veronica-submit.php",
	data: $frm.serialize(),
	success: function( data,  textStatus,  jqXHR ) {
	  $frm.find('.input-group .status').text(data.message);
	},
	dataType: dataType
      });

      alert("SUBMIT");
    });

  }  // End editor
});
