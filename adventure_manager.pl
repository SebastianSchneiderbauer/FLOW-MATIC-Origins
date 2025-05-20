% --- Prolog Text Adventure Engine ---
% Refactored for clarity, robustness, and extensibility
% See HTML guide for best practices

:- dynamic(player/3).
:- dynamic(has/2).
:- dynamic(current_scene/1).
:- discontiguous(scene/4).
:- discontiguous(scene_location/2).

% --- Scene Definitions ---
% Example: scene(ID, Title, Introduction, NextSceneID).
% Scenes should be defined in scene files and included here.
:- include('scenes/scene_01.pl').
:- include('scenes/scene_02.pl').

% --- Game Start ---
start :-
    retractall(player(_,_,_)),
    retractall(has(_,_)),
    retractall(current_scene(_)),
    asserta(player('john doe', 'my house', 100)),
    asserta(current_scene(scene_01)),
    write('Welcome to the Prolog Adventure!'), nl,
    look,
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
    write('Game already started.'), nl, look.
handle_command(look) :-
    player(_, Location, _),
    current_scene(SceneID),
    scene(SceneID, Title, Intro, _),
    write('========================================'), nl,
    write(Title), nl,
    write('========================================'), nl,
    write('Your location: '), write(Location), nl,
    write(Intro), nl,
    list_items(Location),
    list_paths(Location).
handle_command(inventory) :-
    player(Name, _, _),
    findall(Item, has(Name, Item), Items),
    ( Items == [] -> write('Your inventory is empty.'), nl
    ; write('You are carrying:'), nl,
      print_items(Items)
    ).
print_items([]).
print_items([I|T]) :- write('  - '), write(I), nl, print_items(T).
handle_command(take(Item)) :-
    player(Name, Location, _),
    ( item_at(Item, Location) ->
        asserta(has(Name, Item)),
        retract(item_at(Item, Location)),
        write('You take the '), write(Item), write('.'), nl
    ; write('There is no '), write(Item), write(' here.'), nl
    ).
handle_command(drop(Item)) :-
    player(Name, Location, _),
    ( has(Name, Item) ->
        retract(has(Name, Item)),
        asserta(item_at(Item, Location)),
        write('You drop the '), write(Item), write('.'), nl
    ; write('You do not have '), write(Item), write('.'), nl
    ).
handle_command(help) :-
    write('Available commands:'), nl,
    write('  start.         -- start/restart the game'), nl,
    write('  look.          -- look around'), nl,
    write('  take(Object).  -- pick up an object'), nl,
    write('  drop(Object).  -- drop an object'), nl,
    write('  inventory.     -- show your inventory'), nl,
    write('  n. s. e. w.    -- move in a direction'), nl,
    write('  help.          -- show this help'), nl,
    write('  quit.          -- quit the game'), nl.
handle_command(quit) :-
    write('Thanks for playing!'), nl.
handle_command(n) :- move(n).
handle_command(s) :- move(s).
handle_command(e) :- move(e).
handle_command(w) :- move(w).
handle_command(Command) :-
    write('Unknown command: '), write(Command), write('. Try "help."'), nl.

% --- Movement ---
move(Direction) :-
    player(Name, Location, Health),
    ( path(Location, Direction, NewLoc) ->
        retract(player(Name, Location, Health)),
        asserta(player(Name, NewLoc, Health)),
        write('You go '), write(Direction), write(' to '), write(NewLoc), write('.'), nl,
        look,
        ( check_scene_transition(NewLoc) -> true ; true )
    ; write('You cannot go '), write(Direction), write(' from here.'), nl
    ).

% --- Scene Transition ---
check_scene_transition(NewLoc) :-
    scene(SceneID, _, _, _),
    scene_location(SceneID, NewLoc),
    retractall(current_scene(_)),
    asserta(current_scene(SceneID)),
    write('--- New Scene ---'), nl,
    look.

% --- List Items and Paths ---
list_items(Location) :-
    findall(Item, item_at(Item, Location), Items),
    ( Items == [] -> true
    ; print_items_here(Items)
    ).
print_items_here([]).
print_items_here([I|T]) :- write('There is a '), write(I), write(' here.'), nl, print_items_here(T).
list_paths(Location) :-
    findall([Dir,Dest], path(Location, Dir, Dest), Paths),
    ( Paths == [] -> true
    ; print_paths(Paths)
    ).
print_paths([]).
print_paths([[D,L]|T]) :- write('There is a path to the '), write(D), write(' to '), write(L), write('.'), nl, print_paths(T).

% --- Example Dynamic Facts (should be in scene files) ---
% item_at(Item, Location).
% path(From, Direction, To).
% scene_location(SceneID, Location).

% --- Entry Point ---
% To play: ?- start.

% --- End of File ---
% --- look/0 wrapper for compatibility ---
look :- handle_command(look).
