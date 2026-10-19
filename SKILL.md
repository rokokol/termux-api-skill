---
name: termux-api
description: "Use an Android phone's hardware and data from its Termux shell through the termux-api commands: cameras, location, battery, call log and SMS, clipboard, notifications, vibration, torch. Use when a request needs the phone itself rather than an explanation, and when a termux-api command hangs, does nothing or comes back empty. Triggers: take a photo with the phone, where is my phone, phone battery, missed calls, read my sms, termux command hangs, сфоткай с телефона, сделай селфи, где мой телефон, сколько заряда на телефоне, кто мне звонил, прочитай смс, кинь на телефон, покажи на телефоне, включи фонарик, termux-api висит"
license: MIT
---

# termux-api

The `termux-*` commands run in Termux on the phone and need the Termux:API app beside the `termux-api` package; from another machine they go through ssh. `COMMAND -h` is the reference for each command's flags. What follows is what the help does not say

## Every call

- **Wrap it in `timeout`.** A command whose access is missing can hang with no error: `termux-notification-list` reads a listener that Android connects only while Termux:API has the notification access, a special access in the Settings screen rather than a permission dialog, and without it the call blocks until it is killed. Stop a hung call by the PID of its `termux-api` process
- **Expect one to two seconds per call, and one call at a time.** The app serves calls in turn, so two calls meant to happen together are a second apart, and a call that overlaps a timed one delays it
- **Pass text as an argument.** `termux-toast`, `termux-notification` without `-c` and `termux-clipboard-set` read their text from stdin when the arguments carry none, and then take whatever the caller's stdin holds
- **Over ssh, quote every argument for the phone's shell**: ssh joins its arguments into one line that the remote shell splits again, so `ssh PHONE "termux-toast $(printf '%q ' 'two words')"`, never `ssh PHONE termux-toast 'two words'`
- **The data commands return the owner's private data.** Ask for no more than the request needs: `-l N` on the call log and SMS, a field picked out of the JSON on the phone rather than the whole record pulled back

## What Termux cannot do

Termux is an ordinary app, not an adb shell, and its `PATH` holds only `$PREFIX/bin`. `/system/bin/dumpsys` answers `Permission Denial` for want of `android.permission.DUMP`, `pm grant` and `cmd package query-activities` refuse with a `SecurityException`, so a permission or the Doze whitelist needs adb or the Settings screen. `cmd vibrator_manager` accepts a waveform, exits 0 and never vibrates. `am start` from the background prints `Starting:` and does nothing unless Termux holds the special access "Display over other apps" or has a window on the screen. Only the `termux-*` commands reach the hardware, and a command that exits 0 has not thereby done anything: confirm the effect, not the status

## Recipes

- **A photo**: `termux-camera-photo -c ID FILE`, where the IDs and their `facing` come from `termux-camera-info`; it takes about three seconds and writes a JPEG of a few megabytes. Fetch it with `ssh PHONE cat FILE > local.jpg` and delete it on the phone afterwards, since it shows wherever the owner is
- **Where the phone is**: `termux-location -p network -r once` answers in a second or two indoors; `-p gps -r last` returns the last fix without waiting for a new one; `-p gps -r once` waits for a new fix, so it gets a `timeout`
- **State**: `termux-battery-status`, `termux-wifi-connectioninfo` and `termux-telephony-deviceinfo` print one JSON object each
- **The clipboard is write-only**: `termux-clipboard-set TEXT` puts text on the phone, but `termux-clipboard-get` comes back empty with exit 0, because Android lets only the app in focus read the clipboard- **On the screen**: `termux-toast TEXT` for a passing line, `termux-notification` for one that stays; a notification with the same `-i ID` replaces the old one
- **Vibration**: `termux-vibrate -d MS -f` vibrates through silent mode. It returns about 1.5 s after the call whatever the duration and the vibration plays on, and a new vibration cuts short one still playing; a pattern is separate calls started in the background on a schedule, with nothing else in between

## Notifications

- **`--sound` works and `--vibrate PATTERN` does not**: the notification arrives, and the pattern never plays
- **An action — `--action`, `--button1-action`, `--on-delete` — runs under `dash -c` with an empty environment.** Give absolute paths, to a directory that exists: a failing action fails silently, and a press shows nothing on the screen either way, so its effect is the only evidence that it ran
