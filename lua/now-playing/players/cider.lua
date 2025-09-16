local M = {}

M.get_data = function (callback, shell)
  if vim.fn.executable('curl') == 0 then
    -- nc must be executable
    return callback()
  end

  local curl = function (path, cb)
    local cmd = shell.cmd(
      'curl',
      '-sSL',
      string.format('127.0.0.1:10767/api/v1/playback%s', path)
    )

    shell.run(cmd, nil, function (result)
      local output = result.stdout
      if output == '' then
        return callback()
      end

      local valid, json = pcall(vim.json.decode, output)
      if not valid or not json then
        return callback()
      end

      cb(json)
    end)
  end

  local is_running = function (cb)
    curl('/is-playing', function (result)
      if result.status ~= 'ok' then
        return callback()
      end

      cb(result.is_playing)
    end)
  end

  local get_status = function (state)
    curl('/now-playing', function (result)
      if not result.info then
        return callback()
      end
      if not state and result.info.currentPlaybackTime == nil then
        return callback()
      end

      return callback {
        state = state and 'playing' or 'paused',
        position = math.floor(result.info.currentPlaybackTime or 0),
        duration = math.floor((result.info.durationInMillis or 0) / 1000),
        title = result.info.name,
        artist = result.info.artistName,
      }
    end)
  end

  is_running(get_status)
end

return M
