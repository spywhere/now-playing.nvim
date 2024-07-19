local M = {}

M.get_data = function (callback, shell)
  if vim.fn.executable('nowplaying-cli') == 0 then
    -- nc must be executable
    return callback()
  end

  local cmd = function (...)
    return shell.cmd('nowplaying-cli', 'get', ...)
  end

  local is_running = function (cb)
    shell.run(cmd('playbackRate', 'isMusicApp'), function (result)
      local output = result.stdout
      if output == '' then
        return callback()
      end

      local parts = vim.split(output, '\n', { plain = true })
      -- skip if not playing
      if parts[1] == 'null' then
        return callback()
      end
      -- skip music app
      if parts[2] == '1' then
        return callback()
      end

      cb()
    end)
  end

  local get_status = function ()
    shell.run(cmd(
      'playbackRate', 'elapsedTime', 'duration', 'title', 'artist'
    ), function (result)
      local output = result.stdout
      if output == '' then
        return callback()
      end

      local parts = vim.split(output, '\n', { plain = true })

      if not parts[1] or parts[1] == '' or parts[1] == 'null' then
        return callback()
      end

      return callback({
        state = parts[1] == '0' and 'paused' or 'playing',
        position = math.floor(tonumber(parts[2]) or 0),
        duration = math.floor(tonumber(parts[3]) or 0),
        title = parts[4],
        artist = parts[5]
      })
    end)
  end

  is_running(get_status)
end

return M
