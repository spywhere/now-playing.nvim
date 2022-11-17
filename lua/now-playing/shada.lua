local M = {}

M.read_shada = function ()
  if vim.fn.filereadable(vim.env.NOW_PLAYING_SHADA) == 0 then
    return
  end

  local shada = vim.fn.readfile(vim.env.NOW_PLAYING_SHADA, '', 3)

  return {
    priority = tonumber(shada[1]),
    app = shada[2],
    timestamp = tonumber(shada[3])
  }
end

M.write_shada = function (options)
  vim.fn.writefile(
    {
      string.format('%s', options.priority),
      options.app,
      string.format('%s', os.time())
    },
    vim.env.NOW_PLAYING_SHADA,
    'b'
  )
end

M.has_shared_session = function (options)
  local shada = M.read_shada()

  if not shada then
    -- no data
    M.write_shada(options)
    return false
  end

  if shada.priority < options.priority then
    -- self has higher priority
    M.write_shada(options)
    return false
  end

  local now = os.time()

  if shada.app == options.app then
    -- data is self produced

    if shada.timestamp + 5 <= now then
      M.write_shada(options)
    end

    return false
  end

  if shada.timestamp + 10 <= now then
    -- data is too old
    return false
  end

  return true
end

return M
