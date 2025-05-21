% --- Prolog Text Adventure Engine ---
% Refactored for single-scene, room-based navigation
% See HTML guide for best practices

:- dynamic(player/2). % player(Name, Location)
:- dynamic(has/2).
:- dynamic(item_at/2).
:- discontiguous(room/3).
:- discontiguous(room_transition/2).
:- discontiguous(handle_command/1).
:- dynamic(unlocked_object/1).
:- dynamic(shown_scene_text/1).

% --- Room Definitions ---
:- include('scenes/dummy.pl'). % this is the room that will we loaded. Change when testing, transitions are not yet implemented

% --- Splash Screen ---
splash :-
    write('========================================='), nl,
    write('          FLOW-MATIC: ORIGINS'), nl,
    write('========================================='), nl,
    write('  Welcome to the Prolog Text Adventure!'), nl,
    write(''), nl,
    write('Type start. to begin your journey.'), nl, write('> '),
    splash_loop.

splash_loop :-
    read(Input),
    ( Input == start -> start ;
      write('Please type start. to begin the game.'), nl, write('> '),
      splash_loop
    ).

% --- Entry Point ---
:- initialization(splash).

% --- Game Start ---
start :-
    retractall(player(_,_)),
    retractall(has(_,_)),
    scene_reset, % Call scene-specific reset logic
    retractall(shown_scene_text(_)),
    asserta(player('Grace Hopper', my_house)),
    ( room_intro_text(my_house, IntroText) ->
        write(IntroText), nl,
        asserta(shown_scene_text(my_house))
    ; true ),
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
        ( object(Object, Location, locked, _, _),
          blocks_transition(Object, Location, NewRoom),
          \+ unlocked_object(Object) ->
            write('The '), write(Object), write(' is locked. You need to unlock it first.'), nl
        ; retract(player(Name, Location)),
          asserta(player(Name, NewRoom)),
          ( room_transition_text(Location, NewRoom, Text) -> write(Text), nl ; true ),
          ( room_intro_text(NewRoom, IntroText), \+ shown_scene_text(NewRoom) ->
                write(IntroText), nl,
                asserta(shown_scene_text(NewRoom))
            ; true )
        )
    ; write('You cannot go there from here.'), nl
    ), !.
handle_command(look(Object)) :-
    player(_, Location),
    object(Object, Location, locked, _, _),
    ( unlocked_object(Object) ->
        write('The '), write(Object), write(' is unlocked.'), nl
    ; write('The '), write(Object), write(' is locked.'), nl
    ), !.
handle_command(look(_)) :-
    player(_, Location),
    object(_, Location, unlocked, _, _),
    write('The object is unlocked.'), nl, !.
handle_command(look(_)) :-
    write('There is no such thing here.'), nl, !.
handle_command(use(Item)) :-
    player(Name, Location),
    object(Object, Location, locked, Item, UnlockText),
    has(Name, Item),
    ( unlocked_object(Object) ->
        write('The '), write(Object), write(' is already unlocked.'), nl
    ; asserta(unlocked_object(Object)),
      write(UnlockText), nl
    ), !.
handle_command(use(Item)) :-
    player(Name, Location),
    object(Object, Location, locked, Item, _),
    \+ has(Name, Item),
    write('You do not have the '), write(Item), write('.'), nl, !.
handle_command(use(Item)) :-
    player(_, Location),
    object(Object, Location, locked, UnlockItem, _),
    Item \== UnlockItem,
    write('You cannot use that here.'), nl, !.
handle_command(use(_Item)) :-
    write('There is nothing to use that on here.'), nl, !.
handle_command(Command) :-
    write('Unknown command: '), write(Command), write('. Try "help."'), nl.