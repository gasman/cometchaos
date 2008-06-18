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
var gameState;
var selectedSpriteForMovement = null;

/* event chaining */
var pendingEvents = [];
var isExecutingEvents = false;
function chain(fn) {
	if (isExecutingEvents) {
		pendingEvents.push(fn);
	} else {
		/* event functions return false if they're still running asynchronously;
		they'll return nextEvent when complete */
		isExecutingEvents = !fn();
	}
}
function nextEvent() {
	while (fn = pendingEvents.shift()) {
		isExecutingEvents = !fn();
		if (isExecutingEvents) return;
	}
	isExecutingEvents = false;
}

function showConditionalFurniture() {
	jq('.conditional').each(function() {
		var elem = jq(this);
		var show = true;

		var isMyTurn = (personalState == 'choosing_spells' || personalState == 'casting' || personalState == 'fighting');

		if (elem.hasClass('when_game_is_startable') && !gameIsStartable) show = false;
		if (elem.hasClass('when_game_is_joinable') && !gameIsJoinable) show = false;
		if (elem.hasClass('when_game_started') && !gameHasStarted) show = false;
		if (elem.hasClass('when_game_not_started') && gameHasStarted) show = false;
		if (elem.hasClass('when_choosing_spells') && personalState != 'choosing_spells') show = false;
		if (elem.hasClass('when_my_turn') && !isMyTurn) show = false;
		if (elem.hasClass('when_has_pending_spell') && !hasPendingSpell) show = false;
		if (elem.hasClass('when_has_no_pending_spell') && hasPendingSpell) show = false;
		if (elem.hasClass('for_nonplayer') && personalState != 'nonplayer') show = false;
		if (elem.hasClass('for_player') && personalState == 'nonplayer') show = false;
		if (elem.hasClass('for_operator') && !isOperator) show = false;
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

/* Event actions */

function becomePlayer(id) {
	chain(function() {
		myPlayerId = id;
		jq('#player_'+id).addClass('me');
		personalState = 'waiting';
		showConditionalFurniture();
		return true;
	});
}

function putPlayer(id, html) {
	chain(function() {
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
		}
		return true;
	});
}

function removePlayer(id) {
	chain(function() {
		jq('#player_'+id).slideUp('normal', function() {jq(this).remove()});
		if (id == myPlayerId) {
			myPlayerId = null;
			isOperator = false;
			personalState = 'nonplayer';
			showConditionalFurniture();
		}
		return true;
	});
}

function setGameStartable(state) {
	chain(function() {
		gameIsStartable = state;
		showConditionalFurniture();
		return true;
	});
}

function setGameJoinable(state) {
	chain(function() {
		gameIsJoinable = state;
		showConditionalFurniture();
		return true;
	});
}

function announceGame(id, html) {
	chain(function() {
		var game = jq('#game_'+id);
		if (game.length) {
			game.replaceWith(html);
		} else {
			game = jq(html).hide();
			jq('#games_list').append(game);
			game.slideDown();
		}
		return true;
	});
}

function assignOperator(id) {
	chain(function() {
		jq('#player_'+id).addClass('operator');
		if (id == myPlayerId) {
			isOperator = true;
			showConditionalFurniture();
		}
		return true;
	});
}

function revokeOperator(id) {
	chain(function() {
		jq('#player_'+id).removeClass('operator');
		if (id == myPlayerId) {
			isOperator = false;
			showConditionalFurniture();
		}
		return true;
	});
}

function startGame() {
	chain(function() {
		gameHasStarted = true;
		gameIsStartable = false;
		gameIsJoinable = false;
		/* fetch spells */
		jq('#spells_list').load('/games/' + gameId + '/spells', null, applySpellAnchors);
		showConditionalFurniture();
		return true;
	});
}

function beginChoosingSpells() {
	chain(function() {
		jq('#players_list > li').addClass('awaiting_action');
		if (myPlayerId == null) {
			setPrompt('Wizards are choosing spells');			
		} else {
			setPrompt('Choose your spell');
			personalState = 'choosing_spells';
			showConditionalFurniture();
		}
		return true;
	});
}

function endChoosingSpells(id) {
	chain(function() {
		jq('#player_'+id).removeClass('awaiting_action');
		if (id == myPlayerId) {
			personalState = 'waiting';
			setPrompt('Waiting for wizards to choose spells...');
			showConditionalFurniture();
		}
		return true;
	});
}

function markSpellAsChosen(id, html) {
	chain(function() {
		jq('#next_spell').html(html);
		hasPendingSpell = true;
		showConditionalFurniture();
		return true;
	});
}

function beginCasting(playerId, playerName) {
	chain(function() {
		jq('#player_' + playerId).addClass('awaiting_action');
		if (myPlayerId == playerId) {
			personalState = 'casting';
			setPrompt('Your turn');
			jq.get('/games/' + gameId + '/casting_positions', null, showCastingPositions, 'json');
			showConditionalFurniture();
		} else {
			setPrompt(playerName + "\'s turn");
		}
		return true;
	});
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

function discardSpell(id) {
	chain(function() {
		jq('#spell_'+id).slideUp();
		hasPendingSpell = false;
		showConditionalFurniture();
		return true;
	});
}

function endCasting(playerId) {
	chain(function() {
		jq('#player_' + playerId).removeClass('awaiting_action');
		if (myPlayerId == playerId) {
			jq('#board .casting_position').remove();
			personalState = 'waiting';
			showConditionalFurniture();
		}
		return true;
	});
}

function beginFighting(playerId, playerName) {
	chain(function() {
		jq('#player_' + playerId).addClass('awaiting_action');
		if (myPlayerId == playerId) {
			personalState = 'fighting';
			setPrompt('Your turn');
			showConditionalFurniture();
		} else {
			setPrompt(playerName + "\'s turn");
		}
		return true;
	});
}

function endFighting(playerId) {
	chain(function() {
		jq('#player_' + playerId).removeClass('awaiting_action');
		if (myPlayerId == playerId) {
			jq('#board .move_position').remove();
			personalState = 'waiting';
			showConditionalFurniture();
		}
		return true;
	});
}

function putSprite(id, img, x, y, playerId) {
	chain(function() {
		var sprite = jq('#sprite_'+id);
		if (!sprite.length) {
			sprite = jq('<img class="sprite owned_by_player_'+playerId+'" width="32" height="32" alt="" />').attr('id', 'sprite_'+id);
			if (myPlayerId == playerId) {
				sprite.hover(function() {
					if (personalState == 'fighting') {
						jq(this).addClass('highlight');
					}
				}, function() {
					jq(this).removeClass('highlight');
				});
				sprite.click(function() {
					if (personalState == 'fighting') {
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
		}
		sprite.attr('src', img).css({'left': (16+x*32)+'px', 'top': (16+y*32)+'px'});
		jq('#board').append(sprite);
		return true;
	});
}
function removeSprite(id) {
	chain(function() {
		jq('#sprite_'+id).remove();
		return true;
	});
}

function logEvent(html) {
	chain(function() {
		var li = jq('<li></li>').append(html);
		jq('#events_list').append(li);
		return true;
	});
}

function followUpEvent(html) {
	chain(function() {
		jq('#events_list li:last').append(html);
		return true;
	});
}

BOLT_SIZE = 20;
BOLT_SPEED = 9; /* frames per unit distance */

function fireBolt(x0, y0, x1, y1) {
	chain(function() {
		var dx = x1 - x0;
		var dy = y1 - y0;
		if (dx == 0 && dy == 0) {
			return;
		}
		var distance = Math.sqrt(dx*dx + dy*dy);
		var frameCount = Math.floor(distance * BOLT_SPEED);
		boltStep(0, [], frameCount, x0, y0, x1, y1);
		return false;
	});
}
function boltStep(frameNumber, sprites, frameCount, x0, y0, x1, y1) {
	if (frameNumber < frameCount) {
		if (frameNumber < BOLT_SIZE) {
			sprites[frameNumber] = jq('<div class="bolt"></div>');
		}
		var progress = frameNumber / frameCount;
		var x = progress*x1 + (1-progress)*x0;
		var y = progress*y1 + (1-progress)*y0;
		sprites[frameNumber % BOLT_SIZE].css({'left': (32+x*32)+'px', 'top': (32+y*32)+'px'});;
		if (frameNumber < BOLT_SIZE) {
			jq('#board').append(sprites[frameNumber]);
		}
	} else {
		if (sprites[frameNumber % BOLT_SIZE] != null) {
			sprites[frameNumber % BOLT_SIZE].remove();
		}
	}
	if (frameNumber < frameCount + BOLT_SIZE) {
		setTimeout(function() {boltStep(frameNumber + 1, sprites, frameCount, x0, y0, x1, y1)}, 10);
	} else {
		nextEvent();
	}
}

/* end of events */

function setPrompt(text) {
	jq('#prompt_message').text(text);
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

jq(function() {
	applyFormRemoting();
	jq('#players_list .player').each(function() {applyAvatarRollover(jq(this))});
	applySpellAnchors();
	showConditionalFurniture();
	useTransitions = true; /* OK to use transitions after initial page load */
});
