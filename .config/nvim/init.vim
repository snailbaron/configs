call plug#begin('~/.local/share/nvim/plugged')

Plug 'PProvost/vim-ps1'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-vinegar'
Plug 'vim-airline/vim-airline'
Plug 'vim-scripts/Conque-GDB'
Plug 'ludovicchabant/vim-gutentags'
Plug 'Valloric/YouCompleteMe'
Plug 'mikewest/vimroom'
"Plug 'Valloric/YouCompleteMe', {'do': './install.py --clang-completer'}
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

filetype indent off
filetype plugin on

syntax enable

" Create highlight group for improper whitespace usage
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=5 guibg=red

colorscheme desert

set nobackup
set writebackup

set tabstop=4
set shiftwidth=4
set expandtab

set nocindent
set nosmartindent
set autoindent
set backspace=indent,eol,start
set encoding=utf-8
set incsearch
set wildmenu
if &listchars ==# 'eol:$'
    set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif
set formatoptions+=j
set autoread
set history=1000

set number
set hlsearch

set splitright
set splitbelow

" If cursor is on first or last line of the window, scroll to put current line
" in the middle.
function! CenterOnCursorIfOnEdge()
    let cursor_line = winline()
    if cursor_line == 1 || cursor_line == winheight(0)
        normal! zz
    endif
endfunction

nnoremap <silent> <C-]>:call CenterOnCursorIfOnEdge()<CR>
nnoremap <silent> n n:call CenterOnCursorIfOnEdge()<CR>

set mouse=a

"set timeoutlen=0 ttimeoutlen=0
set ttimeoutlen=0

" English, do you speak it?
if has('win32')
    language english
else
    language en_US.UTF-8
endif

inoremap <S-Tab> <C-d>

" Process new buffer creation
autocmd BufNewFile,BufRead * call OnBufferOpen()

""" Colors and highlighting

" Color column 81 with light gray
set colorcolumn=81
highlight ColorColumn ctermbg=magenta

" Indicate current line with deep black
set cursorline
highlight CursorLine cterm=NONE ctermbg=black guibg=black

"
" netrw
"

let g:netrw_banner = 0
let g:netrw_sort_sequence = "[\/]$"

"
" vimroom
"
let g:vimroom_ctermbackground = "none"
let g:vimroom_width = 120
let g:vimroom_sidebar_height = 0

"
" YouCompleteMe
"
" YCM options are documented here:
"     https://github.com/Valloric/YouCompleteMe#options
"

"let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'debug'
"let g:ycm_warning_symbol = '.'
"let g:ycm_error_symbol = '..'
let g:ycm_server_use_vim_stdout = 1

" Fallback global YCM configuration file
"let g:ycm_global_ycm_extra_conf = '~/.global_ycm_extra_conf.py'

" Do not use TAB for selection from completion list
let g:ycm_key_list_select_completion = ['<Down>']
let g:ycm_key_list_previous_completion = ['<Up>']

let g:ycm_warning_symbol = '~>'

" Do not ask if it is safe to load a configuration file. WARNING: allows
" execution of malicious .ycm_extra_conf.py.
let g:ycm_confirm_extra_conf = 0

" Highlight YCM errors with less acid color
highlight YcmErrorSection ctermbg=5

" Mappings for GoTo commands
nmap <F12> :YcmCompleter GoTo<CR>
nmap <C-S-g> :YcmCompleter GoToInclude<CR>

" Terminal

"
" Function to run each time when opening a new buffer
"

function! OnBufferOpen()
    " Highlight unnecessary whitespace
    if &filetype == "cpp"
        match ExtraWhitespace /\s\+$\|\t/
    else
        match ExtraWhitespace /\s\+$/
    endif
endfunction

"
" Seamless resize in Vim/tmux
"

let g:tmux_resize_vertical_step = 3
let g:tmux_resize_horizontal_step = 5

function! s:CanMove(vertical, screenpos)
    if a:vertical
        let windowTop = a:screenpos - winline() + 1
        let windowBottom = windowTop + winheight(0) + 2
        return [windowTop > 1, windowBottom < &lines]
    else
        let windowLeft = a:screenpos - wincol() + 1
        let windowRight = windowLeft + winwidth(0) - 1
        return [windowLeft > 1, windowRight < &columns]
    endif
endfunction

function! s:IsLastTmuxPane(forwardDirection)
    if a:forwardDirection == 'l'
        let pane_right = system("tmux display -p '#{pane_right}'")
        let window_width = system("tmux display -p '#{window_width}'")
        return pane_right + 1 == window_width
    elseif a:forwardDirection == 'j'
        let pane_bottom = system("tmux display -p '#{pane_bottom}'")
        let window_height = system("tmux display -p '#{window_height}'")
        return pane_bottom + 1 == window_height
    endif
endfunction

function! TmuxResize(positive, vertical, tmuxDirection, step, forwardDirection, backDirection)
    let position = [screencol(), screenrow()]
    let canMove = s:CanMove(a:vertical, position[a:vertical])
    let firstWindow = !canMove[0]
    let lastWindow = !canMove[1]
    if lastWindow && (firstWindow || !s:IsLastTmuxPane(a:forwardDirection))
        silent call system('tmux resize-pane -' . a:tmuxDirection . ' ' . a:step)
        "redraw!
    else
        let sign = xor(a:positive, lastWindow) ? '+' : '-'
        let prefix = a:vertical ? '' : 'vertical '
        execute prefix . 'resize ' . sign . a:step
    endif
    "redraw!
endfunction

command! TmuxResizeLeft :call TmuxResize(0, 0, 'L', g:tmux_resize_horizontal_step, 'l', 'h')
command! TmuxResizeRight :call TmuxResize(1, 0, 'R', g:tmux_resize_horizontal_step, 'l', 'h')
command! TmuxResizeDown :call TmuxResize(1, 1, 'D', g:tmux_resize_vertical_step, 'j', 'k')
command! TmuxResizeUp :call TmuxResize(0, 1, 'U', g:tmux_resize_vertical_step, 'j', 'k')

nnoremap <silent> <M-h> :TmuxResizeLeft<CR>
nnoremap <silent> <M-l> :TmuxResizeRight<CR>
nnoremap <silent> <M-j> :TmuxResizeDown<CR>
nnoremap <silent> <M-k> :TmuxResizeUp<CR>

nnoremap <silent> <Esc>h :TmuxResizeLeft<CR>
nnoremap <silent> <Esc>l :TmuxResizeRight<CR>
nnoremap <silent> <Esc>j :TmuxResizeDown<CR>
nnoremap <silent> <Esc>k :TmuxResizeUp<CR>

let g:ycm_server_use_vim_stdout = 1
let g:ycm_server_log_level = 'debug'
