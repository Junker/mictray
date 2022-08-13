[![Build Status](https://travis-ci.com/Junker/mictray.svg?branch=master)](https://travis-ci.com/Junker/mictray)

# MicTray

MicTray is a Lightweight application which lets you control the microphone state and volume from system tray

## Requirements

* PulseAudio
* Gtk
* libnotify
* libkeybinder

## Control

* Left-Button click - mute/unmute
* Middle-Button click - mixer
* Srcoll - Volume up/down
* Hotkey (Default: XF86AudioMicMute) - mute/unmute

## Build & Install

```bash
meson build --prefix=/usr
cd build
ninja
sudo ninja install
```

## Install from Arch Linux & Manjaro

```yaourt -S mictray```

## Install from Ubuntu

```bash
add-apt-repository ppa:mictray/mictray
apt-get update
apt-get install mictray
```

## DBUS

**Path**: /app/junker/mictray \
**Interface**: app.junker.mictray

### DBUS methods

* ToggleMute
* Mute
* Unmute
* IncreaseVolume
* DecreaseVolume

### DBUS usage example

```bash
dbus-send --dest=app.junker.mictray --print-reply /app/junker/mictray app.junker.mictray.ToggleMute
```
