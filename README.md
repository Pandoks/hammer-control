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

**Hammer Control** will repeatedly prompt the user to start the
[SelfControl](https://github.com/SelfControlApp/selfcontrol) session and it will **NOT** stop until
the session is started or the time has passsed the scheduled blocking session.

#### Cancel Proof

If the user tries to cancel the start of a
[SelfControl](https://github.com/SelfControlApp/selfcontrol) session, **Hammer Control** will
automatically try to start another session. It will not stop until the user starts.

#### Mitigating Hiding

A way that a user might get around [Cancel Proofing](#cancel-proof) is to move the password prompt
out of the way to not obstruct any of the distractions that they may be partaking in. If the user
doesn't submit their password for [SelfControl](https://github.com/SelfControlApp/selfcontrol)
in _5 seconds_, **Hammer Control** will restart
[SelfControl](https://github.com/SelfControlApp/selfcontrol) and the prompt will move out of its
hiding spot.

**WARNING:** This also means that you only have _5 seconds_ to input your password before it gets
erased

### Time Change Resistance

**Hammer Control** has it's own internal clock and it periodically verifies the time with an online
source. The user cannot bypass the schedule if they change the local time. When
[SelfControl](https://github.com/SelfControlApp/selfcontrol) starts however, the user can still
bypass it with a time skip. When they change the time back the time, **Hammer Control** will
automatically start another blocking session.

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
