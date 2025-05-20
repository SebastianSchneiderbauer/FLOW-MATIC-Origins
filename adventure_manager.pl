% --- Prolog Text Adventure Engine ---
% Refactored for single-scene, room-based navigation
% See HTML guide for best practices

:- dynamic(player/2). % player(Name, Location)
:- dynamic(has/2).
:- discontiguous(room/3).
:- discontiguous(room_transition/2).
:- discontiguous(handle_command/1).

% --- Room Definitions ---
:- include('scenes/scene_01.pl').

% --- Game Start ---
start :-
    retractall(player(_,_)),
    retractall(has(_,_)),
    asserta(player('john doe', my_house)),
    write('Welcome to the Prolog Adventure!'), nl,
    write('Type help. for a list of commands.'), nl,
    game_loop.

% --- Game Loop ---
game_loop :-
    repeat,
    write('> '),
    read(Command),
    ( Command == end_of_file -> !, fail
    ; catch(handle_command(Command), E, (write('Error: '), write(E), nl, fail)) ->
        (Command == quit -> ! ; true)
      ; write('Unknown command. Try "help."'), nl, fail
    ),
    (Command == quit -> true ; fail).

% --- Command Handlers ---
handle_command(start) :-
    write('Game already started.'), nl.
handle_command(look) :-
    player(_, Location),
    ( room(Location, Desc, _) -> write(Desc), nl ; write('You see nothing special.'), nl ).
handle_command(inventory) :-
    player(Name, _),
    findall(Item, has(Name, Item), Items),
    ( Items == [] -> write('Your inventory is empty.'), nl
    ; write('You are carrying:'), nl,
      print_items(Items)
    ).
print_items([]).
print_items([I|T]) :- write('  - '), write(I), nl, print_items(T).
handle_command(take(Item)) :-
    player(Name, Location),
    ( item_at(Item, Location) ->
        asserta(has(Name, Item)),
        retract(item_at(Item, Location)),
        write('You take the '), write(Item), write('.'), nl
    ; write('There is no '), write(Item), write(' here.'), nl
    ).
handle_command(drop(Item)) :-
    player(Name, Location),
    ( has(Name, Item) ->
        retract(has(Name, Item)),
        asserta(item_at(Item, Location)),
        write('You drop the '), write(Item), write('.'), nl
    ; write('You do not have '), write(Item), write('.'), nl
    ).
handle_command(help) :-
    write('Available commands:'), nl,
    write('  start.         -- start/restart the game'), nl,
    write('  look.          -- look at your current room'), nl,
    write('  move(Room).    -- move to another room'), nl,
    write('  take(Object).  -- pick up an object'), nl,
    write('  drop(Object).  -- drop an object'), nl,
    write('  inventory.     -- show your inventory'), nl,
    write('  help.          -- show this help'), nl,
    write('  quit.          -- quit the game'), nl.
handle_command(quit) :-
    write('Thanks for playing!'), nl.
handle_command(move(NewRoom)) :-
    player(Name, Location),
    ( room_transition(Location, NewRoom) ->
        retract(player(Name, Location)),
        asserta(player(Name, NewRoom)),
        ( room_transition_text(Location, NewRoom, Text) -> write(Text), nl ; true )
    ; write('You cannot go there from here.'), nl
    ).
handle_command(Command) :-
    write('Unknown command: '), write(Command), write('. Try "help."'), nl.

% --- Example Dynamic Facts (should be in scene files) ---
% room(RoomName, Description, [Things...]).
% room_transition(From, To).
% room_transition_text(From, To, Text).
% item_at(Item, Location).

% --- Entry Point ---
% To play: ?- start.

% --- End of File ---
