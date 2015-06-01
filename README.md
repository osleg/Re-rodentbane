# Re-rodentbane
Reincarnation of rodentbane - awesomeWM mouse-less navigation

# Installation 
copy rerodentbane.lua into your `$XDG_HOME/awesome/` directory and add `local rodentbane = require("rerodentbane")` to your `rc.lua` file.
Add a keybind to start the rodentbane to globalkeys eg:
```
awful.key({modkey, }, "q", rerodentbane)
```

Restart awesome and join the fun!

## Usage
Invoking the rerodenbane will draw a grid of 9 boxes
Each box have one button assigned
```
+-+-+-+
|u|i|o|
+-+-+-+                                         
|j|k|l|
+-+-+-+
|n|m|,|
+-+-+-+
```

Pressing one the key will redraw the grid smaller in the area selected.
In average it takes as much as 3 keypresses to get to the place required
Default keybinds for rodentbane:
```
Resize grid:
  +-+-+-+
  |u|i|o|
  +-+-+-+                                         
  |j|k|l|
  +-+-+-+
  |n|m|,|
  +-+-+-+
Move grid:
  SHIFT + h, j, k, l
Undo last move/resize:
  p
Left click:
  Space
Right click:
  Alt+Space
Middle click:
  Shift+Space
Double click:
  Control+Space
Only move mouse:
  Return
```
