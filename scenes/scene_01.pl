% scenes/scene_01.pl - The First Challenge (Refactored)

% --- Scene Definition ---
scene(scene_01, 'Scene 1: The Locked Door',
  'You find yourself in a small, dusty room. There is a large wooden door to the north. It appears to be locked. A small, rusty key is on a table.',
  scene_02).
scene_location(scene_01, 'my house').

% --- Items and Paths ---
item_at(key, 'my house').
path('my house', n, 'garden').

% --- Example: You can add more items or paths as needed ---
