:- dynamic(current_room/1).
:- dynamic(looked_into_drawer/0).

% Initial game state
current_room(desk).

% Room descriptions (Rooms can be seen as states, which have different commands to run)
room_description(desk, 'You sit at your desk. There\'s a drawer and a computer in front of you.').
room_description(computer, 'You are at the computer. The screen is ready.').

% Object descriptions
object_description(desk, drawer, 'You open the drawer and find a sticky note with a password.').
object_description(desk, computer, 'It\'s your work computer, currently locked.').

% Room transition messages
transition_message(desk, computer, 'You move to your computer and enter the password from the sticky note.').
transition_message(computer, desk, 'You move back to your desk.').

% Use transitions (only allowed if drawer was looked into and we're at the desk)
usable_in(desk, computer, computer) :-
	current_room(desk),
	looked_into_drawer, !.

% If not looked into drawer, fail with custom message
usable_in(desk, computer, fail_locked) :-
	current_room(desk),
	\+ looked_into_drawer, !.

% Going back from computer
usable_in(computer, back, desk).

% Game initialization - prints welcome message and initial location
:- initialization(start_game).

start_game :-
    write('*******************************************'), nl,
    write('*   FLOW-MATIC: Origins - Text Adventure  *'), nl,
    write('*******************************************'), nl,
    write('Type "help." for available commands.'), nl, nl,
    write('You wake up in your office. Another day of work...'), nl, nl,
    look.

% Help command to show available actions
help :-
    write('Available commands:'), nl,
    write('  look.                - Look around the current room'), nl,
    write('  look(Object).        - Examine an object (e.g., look(drawer).'), nl,
    write('  use(Object).         - Use or interact with an object (e.g., use(computer).'), nl,
    write('  use(back).           - Go back to previous location when applicable'), nl,
    write('  help.                - Show this help message'), nl, nl.

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

use(computer) :-
	current_room(Room),
	Room \= desk, !,
	write('You need to be at your desk to use the computer.'), nl.

use(Object) :-
	current_room(Room),
	usable_in(Room, Object, NewRoom),
	write('\n'), % Add a newline for clarity
	(transition_message(Room, NewRoom, Msg) -> write(Msg), write('\n\n') ; true),
	retractall(current_room(_)),
	assertz(current_room(NewRoom)),
	look, !.

use(_) :-
	write('You cannot use that here.'), nl.
