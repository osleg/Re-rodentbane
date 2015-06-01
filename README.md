# Re-rodentbane
Reincarnation of rodentbane - awesomeWM mouse-less navigation

# Installation 
copy rerodentbane.lua into your `$XDG_HOME/awesome/` directory and add `local rodentbane = require("rerodentbane")` to your `rc.lua` file.
Add a keybind to start the rodentbane to globalkeys eg:
```
awful.key({modkey, }, "q", rerodentbane)
```

Restart awesome and join the fun!

Default keybinds for rodentbane:
```
Resize grid:
  h, j, k, l
Move grid:
  SHIFT + h, j, k, l
Undo last move/resize:
  u
Left click:
  Space
Right click:
  Shift+Space
Middle click:
  Control+Space
Double click:
  Alt+Space
Only move mouse:
  Return
```
