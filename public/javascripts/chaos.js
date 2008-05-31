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

var useTransitions = false;
var myPlayerId = null;
var currentPlayerId = null;
var myOperatorStatus = false;
var gameState;
var selectedSpriteForMovement = null;
function becomePlayer(id, isOperator) {
	myPlayerId = id;
	myOperatorStatus = isOperator;
	showConditionalFurniture();
}

function showConditionalFurniture() {
	jq('.conditional').each(function() {
		var elem = jq(this);
		var show = true;

		var isMyTurn = (myPlayerId != null && myPlayerId == currentPlayerId);
		if (gameState != 'casting' && gameState != 'combat') isMyTurn = false;

		if (elem.hasClass('when_game_started') && gameState == 'open') show = false;
		if (elem.hasClass('when_game_not_started') && gameState != 'open') show = false;
		if (elem.hasClass('when_choosing_spells') && gameState != 'choosing_spells') show = false;
		if (elem.hasClass('when_my_turn') && !isMyTurn) show = false;
		if (elem.hasClass('when_has_chosen_spell') && !hasChosenSpell) show = false;
		if (elem.hasClass('when_has_not_chosen_spell') && hasChosenSpell) show = false;
		if (elem.hasClass('when_has_pending_spell') && !hasPendingSpell) show = false;
		if (elem.hasClass('when_has_no_pending_spell') && hasPendingSpell) show = false;
		if (elem.hasClass('for_nonplayer') && myPlayerId != null) show = false;
		if (elem.hasClass('for_player') && myPlayerId == null) show = false;
		if (elem.hasClass('for_operator') && myOperatorStatus == false) show = false;
		if (show) {
			if (useTransitions && elem.hasClass('panel')) {
				elem.slideDown();
			} else {
				elem.show();
			}
		} else {
			if (useTransitions && elem.hasClass('panel')) {
				elem.slideUp();
			} else {
				elem.hide();
			}
		}
	})
}

function applyFormRemoting(context) {
	jq('a.remote', context).each(function() {
		var elem = jq(this);
		var httpMethod = findHttpMethodClass(elem);
		elem.click(function() {
			jq.post(elem.attr('href'), {'_method': httpMethod}, function() {}, 'script');
			return false;
		});
	})

	jq('form.remote', context).each(function() {
		var elem = jq(this);
		var httpMethod = findHttpMethodClass(elem);
		elem.submit(function() {
			var params = elem.serialize() + '&_method=' + httpMethod;
			jq.post(elem.attr('action'), params, function() {}, 'script');
			return false;
		});
	})

	return context;
}
function findHttpMethodClass(elem) {
	var httpMethod = 'post';
	if (elem.hasClass('put')) {
		httpMethod = 'put';
	} else if (elem.hasClass('delete')) {
		httpMethod = 'delete';
	}
	return httpMethod;
}

function putPlayer(id, html) {
	var newPlayer = applyAvatarRollover(applyFormRemoting(jq(html)));
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
			showConditionalFurniture();
		}
	}
}

function removePlayer(id) {
	jq('#player_'+id).slideUp('normal', function() {jq(this).remove()});
	if (id == myPlayerId) {
		myPlayerId = null;
		myOperatorStatus = false;
		showConditionalFurniture();
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

function putSprite(id, img, x, y, playerId) {
	var sprite = jq('#sprite_'+id);
	if (!sprite.length) {
		sprite = jq('<img class="sprite owned_by_player_'+playerId+'" width="32" height="32" alt="" />').attr('id', 'sprite_'+id);
		jq('#board').append(sprite);
		sprite.hover(function() {
			if (playerId == myPlayerId && currentPlayerId == myPlayerId && gameState == 'combat') {
				jq(this).addClass('highlight');
			}
		}, function() {
			jq(this).removeClass('highlight');
		});
		sprite.click(function() {
			if (playerId == myPlayerId && currentPlayerId == myPlayerId && gameState == 'combat') {
				if (selectedSpriteForMovement == null) {
					/* clicked on sprite to start movement */
					selectedSpriteForMovement = id;
					jq.get('/sprites/' + id + '/move_positions', null,
						function(positions) {showMovePositions(id, positions)}, 'json');
				} else if (selectedSpriteForMovement == id) {
					/* clicked on sprite again to cancel movement */
					selectedSpriteForMovement = null;
					jq('#board .move_position').remove();
				}
			}
		});
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

function assignOperator(id, status) {
	if (id == myPlayerId) {
		myOperatorStatus = status;
		showConditionalFurniture();
	}
}

function setGameState(state) {
	gameState = state;
	showGameState();
	if (gameState == 'choosing_spells') {
		jq('#players_list > li').addClass('awaiting_action');
		hasPendingSpell = false;
		hasChosenSpell = false;
	}
	showConditionalFurniture();
}
function showGameState() {
	if (gameState == 'open') {
		jq('#game_status').text('Open for joining');
	} else if (gameState == 'choosing_spells') {
		jq('#game_status').text('Choosing spells');
	} else if (gameState == 'casting') {
		jq('#game_status').text('Spellcasting');
	} else if (gameState == 'combat') {
		jq('#game_status').text('Combat');
	} else {
		jq('#game_status').text('unknown... (' + gameState + ')');
	}
}

function startGame() {
	/* fetch spells */
	jq('#spells_list').load('/games/' + gameId + '/spells', null, applySpellAnchors);
}

function applySpellAnchors() {
	jq('#spells_list a.spell').click(function() {
		var newSpellInfo = jq(jq(this).attr('href')).clone();
		applyFormRemoting(newSpellInfo);
		jq('#spell_info_view').replaceWith(newSpellInfo);
		newSpellInfo.attr('id', 'spell_info_view');
		jq('#spells_list a.spell').removeClass('current');
		jq(this).addClass('current')
		return false;
	});
}

function markSpellAsChosen(id, html) {
	jq('#spell_' + id).slideUp();
	jq('#next_spell').html(html);
	hasPendingSpell = true;
	hasChosenSpell = true;
	showConditionalFurniture();
}

function beginCasting(playerId) {
	currentPlayerId = playerId;
	if (myPlayerId == playerId) {
		jq.get('/games/' + gameId + '/casting_positions', null, showCastingPositions, 'json');
	}
	showConditionalFurniture();
}
function showCastingPositions(positions) {
	for (var i = 0; i < positions.length; i++) {
		insertCastingPosition(positions[i][0], positions[i][1]);
	}
}
function insertCastingPosition(x,y) {
	var square = jq('<div class="casting_position"></div>')
	square.css({'left': (16+x*32)+'px', 'top': (16+y*32)+'px'});
	square.click(function() {
		jq.post('/games/' + gameId + '/cast_spell', {'x': x, 'y': y}, function() {}, 'script');
		jq('#board .casting_position').remove();
	});
	jq('#board').append(square);
}

function showMovePositions(spriteId, positions) {
	if (positions.length == 0) {
		selectedSpriteForMovement = null;
	} else {
		for (var i = 0; i < positions.length; i++) {
			insertMovePosition(spriteId, positions[i][0], positions[i][1]);
		}
	}
}
function insertMovePosition(spriteId, x,y) {
	var square = jq('<div class="move_position"></div>')
	square.css({'left': (16+x*32)+'px', 'top': (16+y*32)+'px'});
	square.click(function() {
		jq.post('/sprites/' + spriteId + '/move', {'x': x, 'y': y}, 
			function(positions) {showMovePositions(spriteId, positions)}, 'json');
		jq('#board .move_position').remove();
	});
	jq('#board').append(square);
}

function applyAvatarRollover(player) {
	var playerId = player.attr('id');
	jq('img.avatar', player).hover(function() {
		jq(this).addClass('hover');
		jq('#board .sprite.owned_by_'+playerId).addClass('highlight');
	}, function() {
		jq(this).removeClass('hover');
		jq('#board .sprite.owned_by_'+playerId).removeClass('highlight');
	});
	return player;
}

function beginCombat(playerId) {
	currentPlayerId = playerId;
	showConditionalFurniture();
}

jq(function() {
	applyFormRemoting();
	jq('#players_list .player').each(function() {applyAvatarRollover(jq(this))});
	applySpellAnchors();
	showGameState();
	showConditionalFurniture();
	useTransitions = true; /* OK to use transitions after initial page load */
});
