:- dynamic(current_room/1).
:- dynamic(looked_into_drawer/0).

% Initial game state
current_room(desk).

% Room descriptions
room_description(desk, 'You sit at your desk. There\'s a drawer and a computer in front of you.').
room_description(computer, 'You are at the computer. The screen is ready.').

% Object descriptions
object_description(desk, drawer, 'You open the drawer and find a sticky note with a password.').
object_description(desk, computer, 'It\'s your work computer, currently locked.').

% Use transitions (only allowed if drawer was looked into)
usable_in(desk, computer, computer) :-
	looked_into_drawer, !.

% If not looked into drawer, fail with custom message
usable_in(desk, computer, fail_locked) :-
	\+ looked_into_drawer, !.

% Going back from computer
usable_in(computer, back, desk).

% ---- Commands ----

% look. => look around current room
look :-
	current_room(Room),
	room_description(Room, Desc),
	write(Desc), nl.

% look(Object). => check an object in current room
look(Object) :-
	current_room(Room),
	object_description(Room, Object, Desc),
	write(Desc), nl,
	( Object = drawer -> assertz(looked_into_drawer) ; true ), !.

look(_) :-
	write('You see nothing of interest.'), nl.

% use(Object). => use something, possibly changing rooms
use(Object) :-
	current_room(Room),
	usable_in(Room, Object, fail_locked), !,
	write('The computer is locked. Maybe check the drawer first.'), nl.

use(Object) :-
	current_room(Room),
	usable_in(Room, Object, NewRoom),
	retractall(current_room(_)),
	assertz(current_room(NewRoom)),
	look, !.

use(_) :-
	write('You cannot use that here.'), nl.
