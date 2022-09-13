# now-playing.nvim

_This plugin still under development_

Show currently playing track in neovim status bar

## Integrations

- (macOS only) `osascript` (AppleScript) - enable the following integrations and more in the future
  - Spotity
  - iTunes / Music
- `mpd` ([Music Player Daemon](https://www.musicpd.org)) through `nc` (netcat)

## Configurations

Simply add the following snippets to your favourite status bar manager

```lua
local now_playing = require('now-playing')
now_playing.format(now_playing.status)
```

### Custom Format

To customize a string format, use `.format`.

There are couple of ways to use `.format` to customize the status text

#### Basic Format

For a static, basic custom format, simply passed a string similar to
`string.format`, this would just replace all the placeholder with correspond
data

```lua
require('now-playing').format('%s - %s', 'artist', 'title')
```

Also, this is simply a shorthand version of following setup (see Format
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

You can also use all available format functions below to customize a status
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

#### Format Functions

- `.static`
- `.format`
- `.map`
- `.time`
- `.duration`
- `.scrollable`
