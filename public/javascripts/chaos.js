jq = jQuery.noConflict();

/*
function makeMyNameEditable() {
	jq('#players_list .me').dblclick(function() {
		var nameSpan = jq('.name', this);
		var nameChangeForm = jq('<form action="/players/'+myPlayerId+'/put" method="post"><input name="player[name]" type="text"></form>').val(nameSpan.text());
		var nameInput = jq('input', nameChangeForm).val(nameSpan.text());
		nameSpan.replaceWith(nameChangeForm);
		nameInput.focus();
	});
} */

/* jq(makeMyNameEditable); */

var myPlayerId;
function becomePlayer(id) {
	myPlayerId = id;
}

function addPlayer(id, html) {
	var player = jq(html).hide();
	jq('#players_list').append(player);
	if (id == myPlayerId) {
		player.addClass('me');
		/* makeMyNameEditable(); */
	}
	player.slideDown();
}
function removePlayer(id) {
	jq('#player_'+id).remove();
}

function announceGame(id, html) {
	var game = jq('#game_'+id);
	if (game.length) {
		game.replaceWith(html);
	} else {
		var game = jq(html).hide();
		jq('#games_list').append(game);
		game.slideDown();
	}
}

function putSprite(id, img, x, y) {
	var sprite = jq('#sprite_'+id);
	if (!sprite.length) {
		sprite = jq('<img class="sprite" width="32" height="32" alt="" />');
		jq('#board').append(sprite);
	}
	sprite.attr('src', img).css({'left': (32+x*32)+'px', 'top': (32+y*32)+'px'});
}
