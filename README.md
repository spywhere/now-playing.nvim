# now-playing.nvim

_This plugin still under development_

Show currently playing track in neovim status bar

## Integrations

- (macOS only) `osascript` (AppleScript) - enable the following integrations
and more in the future
  - Spotity
  - iTunes / Music
- `mpd` ([Music Player Daemon](https://www.musicpd.org)) through `nc` (netcat)
- [Cider](https://cider.sh) through `curl`
- [`nowplaying-cli`](https://github.com/kirtan-shah/nowplaying-cli)

## Configurations

Simply add the following snippets to your favourite status bar manager

```lua
local now_playing = require('now-playing')
now_playing.format(now_playing.status)
```

### Additional Customizations

To adjust the plugin-wise configurations, use `.setup` with the configurations
you want to adjust. The following are all available configurations and its
default value

```lua
require('now-playing').setup {
  -- interval in milliseconds for polling for music data
  polling_interval = 5000,
  -- interval in milliseconds for polling for music data during play
  playing_interval = 1000,
  -- maximum duration in milliseconds to allow music data polling per interval
  timeout = 100,
  -- start the polling automatically (using the above timings)
  autostart = true,
  -- application name to be used in a cross plugin interaction
  app = 'nvim',
  -- application priority to be used in a cross plugin interaction
  priority = 1,
  -- force redraw a status line after data fetching
  redraw = false,
  -- customize a playing state icon, any missing state will use a 'default' one
  icon = {
    default = ' ',
    playing = '>'
  }
}
```

### Custom Format

To customize a string format, use `.format`.

There are couple of ways to use `.format` to customize the status text

#### Basic Format

For a static, basic custom format, simply passed a string similar to
`string.format`, this would just replace all the placeholder with correspond
data (see Available Information below)

```lua
require('now-playing').format('%s - %s', 'artist', 'title')
```

Also, this is simply a shorthand version of the following setup (see Format
Functions for more details on `.format`)...

```lua
require('now-playing').format(function (format)
  return format().format('%s - %s', 'artist', 'title')
end)
```

#### Custom Format

For more flexible string format, you can passed a custom function. A
function should accepts a format function as an argument and must returns a
format instance built using a format function provided

For example, to build a custom format that simply returns `hello world`, use

```lua
require('now-playing').format(function (format)
  return format().static('hello world')
end)
```

You can also use all available Format Functions below to customize a status
text to your desire

#### Default Format

Now Playing also provided a default status text
through `require('now-playing').status`, so you can simply passed

```lua
local now_playing = require('now-playing')

now_playing.format(now_playing.status)
```

This default status is built with the following configurations

```lua
M.status = function (format)
  return format()
    .format(
      '%s ',
      format()
        .map('state', {
          -- these icons are taken from the configuration
          playing = '>'
        }, ' ')
    )
    .scrollable(
      25,
      '%s - %s',
      'artist',
      'title'
    )
    .format(
      ' [%s/%s]',
      format().duration('position'),
      format().duration('duration')
    )
end
```

#### Format Functions (to be documented)

The following methods are only available in an object instantiated from a
format builder.

```lua
function (format)
  local format_object = format()
  -- calling method separately does not instantiate a new format
  local format1 = format_object.static('hello')
  local format2 = format_object.static('world')
  -- format_object, format1 and format2 are the same object here
  --   so, the output will simply be 'helloworld'

  -- instantiate a new object will create a new format
  local format3 = format().static('hello')
  local format4 = format().static('world')
  -- format3 and format4 is a different object
  --  so, the output will be
  --    format3 = 'hello'
  --    format4 = 'world'
end
```

- `.static`
- `.format`
- `.map`
- `.time`
- `.duration`
- `.scrollable`

### API (to be documented)

- `.format` (see Custom Format above)
- `.get`
- `.is_running`
- `.is_playing`

### Available Information

All information will be returned when play or paused a track, otherwise an
empty string will be used instead

- `title`: A title of currently playing track
- `artist`: An artist of currently playing track
- `position`: A playing position in seconds of currently playing track
- `duration`: A total duration in seconds of currently playing track
- `state`: A playing state (`playing`, `paused`)
- `app`: A music player name

### Cross Plugin Interaction (to be documented)

now-playing.nvim can be setup so it work with tmux-now-playing seamlessly.

Both plugin will set the status based on how plugin are running on both apps.

When both installed and setup, tmux-now-playing will take over first and set
a tmux status to show a currently playing track. Once neovim is opened and
now-playing.nvim requested to take over, tmux-now-playing will switch its
status to a shared session one (default to empty string, which simply hide
the playing status). And once neovim is closed, in a few seconds,
tmux-now-playing will take control of the status back to tmux
