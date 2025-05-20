% scenes/scene_01.pl - Room and transition definitions for the adventure

% --- Room Definitions ---
room(my_house, 'A small, dusty room. There is a large wooden door to the north. A small, rusty key is on a table.', []).
room(garden, 'A quiet garden with overgrown grass. There is a path leading to a shed.', []).
room(shed, 'A dark, cramped shed. There are some old tools here.', []).

% --- Room Transitions ---
room_transition(my_house, garden).
room_transition(garden, my_house).
room_transition(garden, shed).
room_transition(shed, garden).

% --- Transition Texts ---
room_transition_text(my_house, garden, 'You step through the door into the garden.').
room_transition_text(garden, my_house, 'You walk back into the house.').
room_transition_text(garden, shed, 'You walk into the shed.').
room_transition_text(shed, garden, 'You leave the shed and return to the garden.').

% --- Items ---
item_at(key, my_house).

% --- Objects/Locks ---
% object(Object, Location, locked|unlocked, UnlockItem, UnlockText)
object(door, my_house, locked, key, 'You use the key to unlock the door. Behind it you see the garden').

% --- Scene Startup Text ---
scene_startup_text(my_house, 'You awaken in your house, unsure how you got here. The air is thick with dust and mystery.').
scene_startup_text(garden, 'The garden is overgrown, but you feel a strange sense of calm as you step outside.').
scene_startup_text(shed, 'The shed is dark and cramped, filled with the scent of old tools and rust.').
