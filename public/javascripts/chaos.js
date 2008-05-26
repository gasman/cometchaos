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

var myPlayerId = null;
function becomePlayer(id) {
	myPlayerId = id;
}

function showFurnitureForPlayer() {
	jq('.for_nonplayer').hide();
	jq('.for_player').show();
}
function showFurnitureForNonPlayer() {
	jq('.for_player').hide();
	jq('.for_nonplayer').show();
}

jq(function() {
	var x = 1;
	if (myPlayerId == null) {
		showFurnitureForNonPlayer();
	} else {
		showFurnitureForPlayer();
	}
});

function putPlayer(id, html) {
	var newPlayer = jq(html);
	if (id == myPlayerId) {
		newPlayer.addClass('me');
		/* makeMyNameEditable(); */
	}

	var player = jq('#player_'+id);
	if (player.length) {
		player.replaceWith(newPlayer);
	} else {
		newPlayer.hide();
		jq('#players_list').append(newPlayer);
		newPlayer.slideDown();
		if (id == myPlayerId) {
			showFurnitureForPlayer();
		}
	}
}

function removePlayer(id) {
	jq('#player_'+id).remove();
	if (id == myPlayerId) {
		showFurnitureForNonPlayer();
	}
}

function announceGame(id, html) {
	var game = jq('#game_'+id);
	if (game.length) {
		game.replaceWith(html);
	} else {
		game = jq(html).hide();
		jq('#games_list').append(game);
		game.slideDown();
	}
}

function putSprite(id, img, x, y) {
	var sprite = jq('#sprite_'+id);
	if (!sprite.length) {
		sprite = jq('<img class="sprite" width="32" height="32" alt="" />').attr('id', 'sprite_'+id);
		jq('#board').append(sprite);
	}
	sprite.attr('src', img).css({'left': (16+x*32)+'px', 'top': (16+y*32)+'px'});
}
function removeSprite(id) {
	jq('#sprite_'+id).remove();
}

function logEvent(html) {
	var li = jq('<li></li>').append(html);
	jq('#events_list').append(li);
}
