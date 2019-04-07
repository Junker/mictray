[![Build Status](https://travis-ci.com/Junker/mictray.svg?branch=master)](https://travis-ci.org/Junker/mictray)

# MicTray
MicTray is a Lightweight application which lets you control the microphone state and volume from system tray

### Requirements
* PulseAudio
* Gtk

### Control
* Left-Button click - mute/unmute
* Middle-Button click - mixer
* Srcoll - Volume up/down

### Build & Install

	meson build --prefix=/usr
	cd build
	ninja
	sudo ninja install

### Install from Arch Linux & Manjaro 
	yaourt -S mictray
