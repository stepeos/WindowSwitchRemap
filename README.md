# WindowSwitchRemap

a MacOS app for remapping the built-in app-switching hotkey from Command+Tab to Control+Tab to emulate default windows and Ubuntu behavior.

**Q: Why use this and not Karabiner?**

**A:** Well, there's a whopping 143 LOC for you to check, while Karabiner is far more complex and is quite a bulky app. The app is meant for those who have to trust the code they run.

## Compiling the app
```
git clone git@github.com:stepeos/WindowSwitchRemap.git
cd WindowSwitchRemap
mkdir build  && cd build
cmake ..
cmake --build .
```

If you're using ZSH, then you can just start the app in the background like this:
```
./WindowSwitchRemap.app/Contents/MacOS/WindowSwitchRemap &disown
```
Enojoy :^)
