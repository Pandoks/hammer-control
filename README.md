# 🔨 Hammer Control

A script that uses [hammerspoon](https://github.com/Hammerspoon/hammerspoon) to create schedules
for [SelfControl](https://github.com/SelfControlApp/selfcontrol).

**WARNING:** I've built this script to my preferences so there may be a lot of bugs that haven't
been caught. Submit an issue or pull request if you do find one though.

## Features

### Auto-Fill Password

**Hammer Control** uses your password stored in _Apple Keychain_ to automatically fill out
[SelfControl's](https://github.com/SelfControlApp/selfcontrol) prompt to install a helper. Usually
you would need to do this manually, but **Hammer Control** will do it for you so quickly that you
will barely notice it. There will be a quick popup indicating that
[SelfControl](https://github.com/SelfControlApp/selfcontrol) started, but it fades away by itself
quickly.

<p align="center">
  <img src="https://github.com/Pandoks/hammer-control/assets/35944715/156fd7e6-6cb1-4630-8a53-07c28f7862cd" width=70% height=70%>
</p>

### Time Change Resistance

**Hammer Control** has it's own internal clock and it periodically verifies the time with an online
source. The user cannot bypass the schedule if they change the local time. When
[SelfControl](https://github.com/SelfControlApp/selfcontrol) starts however, the user can still
bypass it with a time skip. When they change the time back, **Hammer Control** will
automatically start another blocking session.

## Installation

### Prerequisites

- hammerspoon
  - `brew install hammerspoon`
- SelfControl
  - `brew install selfcontrol`

### Installer

Use the installer to setup **Hammer Control**:

```sh
git clone https://github.com/Pandoks/hammer-control.git
cd hammer-control
./install
```

### Manual Installation

1. Make [hammerspoon](https://github.com/Hammerspoon/hammerspoon) directory

   ```sh
   mkdir ~/.hammerspoon
   ```

1. Clone directory to [hammerspoon](https://github.com/Hammerspoon/hammerspoon) directory

   ```sh
   git clone https://github.com/Pandoks/hammer-control.git ~/.hammerspoon/hammer-control
   ```

1. Create `init.lua` for [hammerspoon](https://github.com/Hammerspoon/hammerspoon)

   ```sh
   touch ~/.hammerspoon/init.lua
   ```

1. Add `require("hammer-control")` to your `init.lua` file

   ```sh
   echo 'require("hammer-control")' | cat - ~/.hammerspoon/init.lua > temp && mv temp ~/.hammerspoon/init.lua
   ```

1. Add your password to _Apple Keychain_

   ```sh
   security add-generic-password -a $(whoami) -s hammer-control -w
   ```

### Updates

To update, you can just `git pull` inside of `~/.hammerspoon/hammer-control` directory.

```sh
git pull
```

Remember to reload [hammerspoon](https://github.com/Hammerspoon/hammerspoon) config after pulling.

## Usage

### Blocklist

**Hammer Control** uses blacklists saved from
[SelfControl](https://github.com/SelfControlApp/selfcontrol). You can save a blacklist
(a `.selfcontrol` file) by pressing `⌘ + s` while
[SelfControl](https://github.com/SelfControlApp/selfcontrol) is open. Make sure to remember the
full path to the file starting from your home (`~`) directory, because you will need it to
create a schedule.

### schedule.json

To create a schedule, create a `schedule.json` file in the `~/.hammerspoon/hammer-control`
directory. If you want to use the `example-schedule.json` as a reference, you can copy it over with
`cp ~/.hammerspoon/hammer-control/example-schedule.json ~/.hammerspoon/hammer-control/schedule.json`
or copy and paste this into your `schedule.json` file:

```json
{
  "sunday": [],
  "monday": [
    {
      "start": "23:00",
      "end": "23:20",
      "blocklist": "~/Desktop/distractions.selfcontrol"
    }
  ],
  "tuesday": [],
  "wednesday": [],
  "thursday": [
    {
      "start": "03:00",
      "end": "04:20",
      "blocklist": "~/.hammerspoon/hammer-control/social-media.selfcontrol"
    },
    {
      "start": "23:00",
      "end": "23:20",
      "blocklist": "~/.hammerspoon/hammer-control/blacklist.selfcontrol"
    }
  ],
  "friday": [],
  "saturday": []
}
```

The `json` file must contain all of the days of the week in lower case and have their values as
list of objects. Each object has a `start`, `end`, and `blocklist` property. `start` and `end` are
times in **24 hour format** indicating when the scheduled blocking session starts and ends on that
specific day. `blocklist` is the file that [SelfControl](https://github.com/SelfControlApp/selfcontrol)
uses as the blacklist. _Ideally_, the path to the `.selfcontrol` file is absolute, referencing its
location from the home (`~`) directory.

**NOTE:** The hour needs to be 2 digits. `2:00` won't work. `02:00` will work.

## Troubleshooting

- Restarting your system may help
