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
var myOperatorStatus = false;
function becomePlayer(id, isOperator) {
	myPlayerId = id;
	myOperatorStatus = isOperator;
	showFurnitureForPlayer();
	indicateOperatorStatus();
}

function showFurnitureForPlayer() {
	if (useTransitions) {
		jq('.for_nonplayer').slideUp();
		jq('.for_player').slideDown();
	} else {
		jq('.for_nonplayer').hide();
		jq('.for_player').show();
	}
}
function showFurnitureForNonPlayer() {
	if (useTransitions) {
		jq('.for_player').slideUp();
		jq('.for_nonplayer').slideDown();
	} else {
		jq('.for_player').hide();
		jq('.for_nonplayer').show();
	}
}
function indicateOperatorStatus() {
	if (myOperatorStatus) {
		jq('body').addClass('i_am_operator');
	} else {
		jq('body').removeClass('i_am_operator');
	}
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

jq(function() {
	applyFormRemoting();
	if (myPlayerId == null) {
		showFurnitureForNonPlayer();
	} else {
		showFurnitureForPlayer();
	}
	indicateOperatorStatus();
	useTransitions = true; /* OK to use transitions after initial page load */
});

function putPlayer(id, html) {
	var newPlayer = applyFormRemoting(jq(html));
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

function assignOperator(id, status) {
	if (id == myPlayerId) {
		myOperatorStatus = status;
		indicateOperatorStatus();
	}
}