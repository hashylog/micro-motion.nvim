-- micro-motion.nvim

local M = {}

-----------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------

--- Check if a character is whitespace.
---@param char string
---@return boolean
local function is_whitespace(char)
    return char:match("^%s$") ~= nil
end

--- Check if a character is a word character (letter, digit, or underscore).
---@param char string
---@return boolean
local function is_word_char(char)
    return char:match("^[%w_]$") ~= nil
end

--- Check if a character is a non-word, non-whitespace character.
---@param char string
---@return boolean
local function is_non_word_char(char)
    return not is_word_char(char) and not is_whitespace(char)
end

--- Get a character from a given line and column index (0-based).
---@param line string
---@param col integer
---@return string
local function get_char_at(line, col)
    if col < 0 or col >= #line then
        return ""
    end
    return line:sub(col + 1, col + 1)
end

-----------------------------------------------------------
-- Motion: Move Right
-----------------------------------------------------------

--- Move cursor one "word" to the right.
function M.word_right()
    local line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- If at end of line, move to start of next line
    if col >= #line then
        if row < vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
        end
        return
    end

    local start_col = col
    local current_char = get_char_at(line, col)

    -- Skip initial whitespace
    while col < #line and is_whitespace(get_char_at(line, col)) do
        col = col + 1
    end

    -- If we skipped whitespace, stop here
    if col > start_col then
        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    -- Case 1: Non-word characters (punctuation, symbols, etc.)
    if is_non_word_char(current_char) then
        -- Skip a block of consecutive non-word characters
        if col + 1 < #line and is_non_word_char(get_char_at(line, col + 1)) then
            while col < #line and is_non_word_char(get_char_at(line, col)) and not is_whitespace(get_char_at(line, col)) do
                col = col + 1
            end
        else
            -- Otherwise, move just one char
            col = col + 1
        end

    -- Case 2: Word characters
    else
        -- Move forward through the rest of the word
        col = col + 1
        while col < #line and is_word_char(get_char_at(line, col)) do
            col = col + 1
        end
    end

    vim.api.nvim_win_set_cursor(0, { row, col })
end

-----------------------------------------------------------
-- Motion: Move Left
-----------------------------------------------------------

--- Move cursor one "word" to the left.
function M.word_left()
    local line = vim.api.nvim_get_current_line()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- If at start of line, move to end of previous line
    if col == 0 then
        if row > 1 then
            local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
            vim.api.nvim_win_set_cursor(0, { row - 1, #prev_line })
        end
        return
    end

    col = col - 1
    local start_col = col

    -- Skip whitespace to the left
    while col > 0 and is_whitespace(get_char_at(line, col)) do
        col = col - 1
    end

    -- If we skipped whitespace, stop right after last non-space
    if col < start_col and col >= 0 then
        if not is_whitespace(get_char_at(line, col)) then
            col = col + 1
        end
        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    local current_char = get_char_at(line, col)

    -- Case 1: Non-word characters
    if is_non_word_char(current_char) then
        -- Skip a block of consecutive non-word characters
        if col > 0 and is_non_word_char(get_char_at(line, col - 1)) then
            while col > 0 and is_non_word_char(get_char_at(line, col)) and not is_whitespace(get_char_at(line, col)) do
                col = col - 1
            end
            -- Adjust if we went one too far
            if not is_non_word_char(get_char_at(line, col)) or is_whitespace(get_char_at(line, col)) then
                col = col + 1
            end
        end

    -- Case 2: Word characters
    else
        -- Move backward through the rest of the word
        col = col - 1
        while col >= 0 and is_word_char(get_char_at(line, col)) do
            col = col - 1
        end
        col = col + 1
    end

    vim.api.nvim_win_set_cursor(0, { row, col })
end

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------

--- Set up navigation keymaps.
function M.setup()

    local opts = { noremap = true, silent = true }

    -- Normal mode
    vim.keymap.set('n', '<C-Right>', M.word_right, vim.tbl_extend('force', opts, { desc = 'Micro-style word right' }))
    vim.keymap.set('n', '<C-Left>',  M.word_left,  vim.tbl_extend('force', opts, { desc = 'Micro-style word left' }))

    -- Insert mode
    vim.keymap.set('i', '<C-Right>', M.word_right, vim.tbl_extend('force', opts, { desc = 'Micro-style word right' }))
    vim.keymap.set('i', '<C-Left>',  M.word_left,  vim.tbl_extend('force', opts, { desc = 'Micro-style word left' }))

    -- Visual mode
    vim.keymap.set('v', '<C-Right>', M.word_right, vim.tbl_extend('force', opts, { desc = 'Micro-style word right' }))
    vim.keymap.set('v', '<C-Left>',  M.word_left,  vim.tbl_extend('force', opts, { desc = 'Micro-style word left' }))

end

return M
