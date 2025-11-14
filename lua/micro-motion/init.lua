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

--- Move cursor one "word" to the right (Micro Editor style).
--- Stops at the END of tokens (right after the last character, before any trailing whitespace).
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

    local current_char = get_char_at(line, col)

    -- If currently on whitespace, skip all whitespace first
    if is_whitespace(current_char) then
        while col < #line and is_whitespace(get_char_at(line, col)) do
            col = col + 1
        end
        -- After skipping whitespace, continue to skip the next token
        if col >= #line then
            vim.api.nvim_win_set_cursor(0, { row, col })
            return
        end
        current_char = get_char_at(line, col)
    end

    -- Now we're on a non-whitespace character, skip to end of this token
    if is_word_char(current_char) then
        -- Skip to end of word
        while col < #line and is_word_char(get_char_at(line, col)) do
            col = col + 1
        end
        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    -- If on non-word character (punctuation), check if it's a block or single char
    if is_non_word_char(current_char) then
        -- Check if next char is also non-word (forming a block)
        if col + 1 < #line and is_non_word_char(get_char_at(line, col + 1)) then
            -- Skip entire block of non-word characters
            while col < #line and is_non_word_char(get_char_at(line, col)) do
                col = col + 1
            end
        else
            -- Single non-word char, just move past it
            col = col + 1
        end
        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    -- Fallback: just move one position
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
end

-----------------------------------------------------------
-- Motion: Move Left
-----------------------------------------------------------

--- Move cursor one "word" to the left (Micro Editor style).
--- Stops at the START of tokens (after any leading whitespace).
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

    -- Move back one position first
    col = col - 1
    local current_char = get_char_at(line, col)

    -- If we land on whitespace, skip all whitespace and continue to the token before it
    if is_whitespace(current_char) then
        -- Skip all whitespace
        while col >= 0 and is_whitespace(get_char_at(line, col)) do
            col = col - 1
        end

        -- If we went past the start, stop at position 0
        if col < 0 then
            vim.api.nvim_win_set_cursor(0, { row, 0 })
            return
        end

        -- Now we're on a non-whitespace character, go back to start of this token
        current_char = get_char_at(line, col)

        if is_word_char(current_char) then
            while col > 0 and is_word_char(get_char_at(line, col - 1)) do
                col = col - 1
            end
        elseif is_non_word_char(current_char) then
            -- Check if it's a block of non-word chars
            if col > 0 and is_non_word_char(get_char_at(line, col - 1)) then
                while col > 0 and is_non_word_char(get_char_at(line, col - 1)) do
                    col = col - 1
                end
            end
        end

        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    -- If we land on a word character, go back to start of word
    if is_word_char(current_char) then
        while col > 0 and is_word_char(get_char_at(line, col - 1)) do
            col = col - 1
        end
        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    -- If we land on a non-word character
    if is_non_word_char(current_char) then
        -- Check if it's a block of non-word chars
        if col > 0 and is_non_word_char(get_char_at(line, col - 1)) then
            while col > 0 and is_non_word_char(get_char_at(line, col - 1)) do
                col = col - 1
            end
        end
        vim.api.nvim_win_set_cursor(0, { row, col })
        return
    end

    -- Fallback
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
