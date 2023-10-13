# 🔨 Hammer Control

A script that uses [hammerspoon](https://github.com/Hammerspoon/hammerspoon) to create schedules
for [SelfControl](https://github.com/SelfControlApp/selfcontrol).

## Features

### Annoyance

Since `v4` of [SelfControl](https://github.com/SelfControlApp/selfcontrol) couldn't get around
prompting the user for the admin password to start the program, it made auto-scheduling scripts
like [auto-selfcontrol](https://github.com/andreasgrill/auto-selfcontrol) not as effective since
the user would have to consciously start the session. Someone could easily just click cancel and
[SelfControl](https://github.com/SelfControlApp/selfcontrol) would be useless. It was much better
when you could forget about it, so when you got distracted, you wouldn't have the chance to fight
back.

Although I couldn't get around the password prompting problem, something I could do is annoy the
living hell out the of the user if they don't start the
[SelfControl](https://github.com/SelfControlApp/selfcontrol) session.

#### Mitigating Hiding

## Installation

### Prerequisites

- hammerspoon
  - `brew install hammerspoon`
- SelfControl
  - `brew install selfcontrol`

### Setup

1. `mkdir ~/.hammerspoon` if it doesn't exist.
1. `git clone https://github.com/Pandoks/hammer-control.git ~/.hammerspoon/hammer-control`
1. `touch ~/.hammerspoon/init.lua` if it doesn't exist.
1. `sed -i '1s/^/require("hammer-control")\n/' ~/.hammerspoon/init.lua`
   - or manually add `require("hammer-control")` to your `init.lua` file

## Usage
