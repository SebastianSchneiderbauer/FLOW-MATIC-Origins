% scenes/dummy.pl - a dummy file for developers to see how the engine works

% --- Room Definitions ---
% room(Name, Description, Items) Items should be a empty list
room(my_house, 'A small, dusty room. There is a large wooden door to the north. A small, rusty key is on a table.', []).
room(garden, 'A quiet garden with overgrown grass. There is a path leading to a shed.', []).
room(shed, 'A dark, cramped shed. There are some old tools here.', []).

% --- Room Transitions ---
% room_transition(CurrentRoom, NextRoom)
room_transition(my_house, garden).
room_transition(garden, my_house).
room_transition(garden, shed).
room_transition(shed, garden).

% --- Room Intro Text ---
% room_intro_text(Room, Text) text thats showed when entering the room for the first time
room_intro_text(my_house, 'You awaken in your house, unsure how you got here. The air is thick with dust and mystery.').
room_intro_text(garden, 'The garden is overgrown, but you feel a strange sense of calm as you step outside.').
room_intro_text(shed, 'The shed is dark and cramped, filled with the scent of old tools and rust.').

% --- Room Transition Texts ---
% room_transition_text(CurrentRoom, NextRoom, Text) text that is shown when moving between rooms
room_transition_text(my_house, garden, 'You step through the door into the garden.').
room_transition_text(garden, my_house, 'You walk back into the house.').
room_transition_text(garden, shed, 'You walk into the shed.').
room_transition_text(shed, garden, 'You leave the shed and return to the garden.').

% --- Items ---
% item(Name, Location)
item_at(key, my_house).

% --- Objects/Locks ---
% object(Object, Location, locked|unlocked, UnlockItem, UnlockText) e.g. is a door locked
object(door, my_house, locked, key, 'You use the key to unlock the door. Behind it you see the garden').

% --- Transition Blocked by Door ---
% blocks_transition(Object, FromRoom, ToRoom)
blocks_transition(door, my_house, garden).

% --- Scene Reset Logic ---
% scene_reset/0: Resets all dynamic state for this scene (e.g., unlocked objects)
scene_reset :-
    retractall(unlocked_object(door)).


