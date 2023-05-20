for _, source in ipairs {
  "astronvim.bootstrap",
  "astronvim.options",
  "astronvim.lazy",
  "astronvim.autocmds",
  "astronvim.mappings",
} do
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

if astronvim.default_colorscheme then
  if not pcall(vim.cmd.colorscheme, astronvim.default_colorscheme) then
    require("astronvim.utils").notify(
      "Error setting up colorscheme: " .. astronvim.default_colorscheme,
      vim.log.levels.ERROR
    )
  end
end

_G.close_buffers = function()
    -- Check if the input buffer exists

    if vim.fn.bufexists('input_buffer') == 1 then
        -- Close the input buffer
        vim.cmd('silent! execute "bdelete! " .. bufnr("input_buffer")')
    end

    -- Check if the output buffer exists
    if vim.fn.bufexists('output_buffer') == 1 then
        -- Close the output buffer
        vim.cmd('silent! execute "bdelete! " .. bufnr("output_buffer")')
    end
end

local cp_buffers_open = false
_G.code_buffer = nil

_G.toggle_cp_buffer = function()
    local file = vim.fn.expand('%:p')  -- Get the full path of the current file

    --if vim.fn.bufexists('input_buffer') == 1 and vim.fn.bufexists('output_buffer') == 1 then
    if cp_buffers_open then
        -- Close the buffers if they are already open
        _G.close_buffers()
    else
        if file:match(".cpp$") then  -- Check if the current file is a .cpp file
            _G.code_buffer = vim.fn.bufnr('%')
            -- Create a horizontal split
            vim.cmd('botright new')
            -- Set the buffer name for the input window
            vim.cmd('file input_buffer')

            -- Create a vertical split
            vim.cmd('vnew')
            -- Set the buffer name for the output window
            vim.cmd('file output_buffer')
        else
            print("The current file is not a .cpp file.")
        end
    end
    cp_buffers_open = not cp_buffers_open
end

vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>lua _G.toggle_cp_buffer()<CR>', {noremap = true, silent = true})

_G.run_cpp = function(compile)
    vim.cmd('write!')
    -- If the buffers don't exist, create them
    if vim.fn.bufexists('input_buffer') == 0 or vim.fn.bufexists('output_buffer') == 0 then
        _G.toggle_cp_buffer()
    end

    -- Save the current buffer
    vim.cmd('update')

    -- Remember the buffer with your code
    -- Get the contents of the input buffer
    local input = vim.api.nvim_buf_get_lines(vim.fn.bufnr('input_buffer'), 0, -1, false)

    -- Write the input to a temporary file
    local input_file = os.tmpname()
    local file = io.open(input_file, 'w')
    for _, line in ipairs(input) do
        file:write(line .. '\n')
    end
    file:close()

    print("create input file ok")

    -- Compile the .cpp file
    local file = vim.fn.fnamemodify(vim.fn.bufname(_G.code_buffer), ':p') -- Get the full path of the current file
    if compile then
        vim.cmd('!g++ ' .. file .. ' -o ' .. file .. '.out')
    end

    print("compile ok")

    -- Run the compiled program with the input
    local file = file .. '.out'  -- Get the full path of the compiled program
    local handle = io.popen('cat ' .. input_file .. ' | ' .. file)
    local output = handle:read('*a')
    handle:close()

    print("run compiled program ok")

    -- Display the output in the output buffer
    vim.api.nvim_buf_set_lines(vim.fn.bufnr('output_buffer'), 0, -1, false, vim.split(output, '\n'))

    -- Delete the temporary file
    os.remove(input_file)
end

vim.api.nvim_set_keymap('n', '<leader>cp', '<cmd>lua _G.run_cpp(true)<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<leader>c[', '<cmd>lua _G.run_cpp(false)<CR>', {noremap = true, silent = true})

