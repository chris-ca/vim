execute pathogen#infect()

" Theme, Window, Look and Feel {
    set background=dark
    colorscheme solarized

    " will degrade colors if used in linux shell session
    let g:solarized_termcolors=256

    " use 256 colors in Console mode if we think the terminal supports it
    " this is REQUIRED for colors to work properly in screen session
    set t_Co=256

    set ruler
    set cursorline
    set backspace=indent,eol,start " Backspace for dummies
    set showmode
    set nu              " Line numbers on
    set relativenumber  " Line numbers relative
    set showmatch       " Show matching brackets/parenthesis
    set winminheight=0  " Windows can be 0 line high
    
    if has('statusline')
        set laststatus=2
        " Broken down into easily includeable segments
        set statusline=%<%f\ " Filename
        set statusline+=%w%h%m%r " Options
        set statusline+=%{fugitive#statusline()} " Git Hotness
        set statusline+=\ [%{&ff}/%Y] " Filetype
        set statusline+=\ [%{getcwd()}] " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%% " Right aligned file nav info
    endif

    " Change the color scheme from a list of color scheme names.
    " Version 2010-09-12 from http://vim.wikia.com/wiki/VimTip341
    " Press key:
    "   F8                next scheme
    "   Shift-F8          previous scheme
    "   Alt-F8            random scheme
    " {{{
        " Set the list of color schemes used by the above (default is 'all'):
        "   :SetColors all              (all $VIMRUNTIME/colors/*.vim)
        "   :SetColors my               (names built into script)
        "   :SetColors blue slate ron   (these schemes)
        "   :SetColors                  (display current scheme names)
        " Set the current color scheme based on time of day:
        "   :SetColors now
        if v:version < 700 || exists('loaded_setcolors') || &cp
          finish
        endif

        let loaded_setcolors = 1
        let s:mycolors = ['solarized','slate', 'torte', 'darkblue', 'delek', 'murphy', 'elflord', 'pablo', 'koehler']  " colorscheme names that we use to set color

        " Set list of color scheme names that we will use, except
        " argument 'now' actually changes the current color scheme.
        function! s:SetColors(args)
          if len(a:args) == 0
            echo 'Current color scheme names:'
            let i = 0
            while i < len(s:mycolors)
              echo '  '.join(map(s:mycolors[i : i+4], 'printf("%-14s", v:val)'))
              let i += 5
            endwhile
          elseif a:args == 'all'
            let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
            let s:mycolors = map(paths, 'fnamemodify(v:val, ":t:r")')
            echo 'List of colors set from all installed color schemes'
          elseif a:args == 'my'
            let c1 = 'default elflord peachpuff desert256 breeze morning'
            let c2 = 'darkblue gothic aqua earth black_angus relaxedgreen'
            let c3 = 'darkblack freya motus impact less chocolateliquor'
            let s:mycolors = split(c1.' '.c2.' '.c3)
            echo 'List of colors set from built-in names'
          elseif a:args == 'now'
            call s:HourColor()
          else
            let s:mycolors = split(a:args)
            echo 'List of colors set from argument (space-separated names)'
          endif
        endfunction

        command! -nargs=* SetColors call s:SetColors('<args>')

        " Set next/previous/random (how = 1/-1/0) color from our list of colors.
        " The 'random' index is actually set from the current time in seconds.
        " Global (no 's:') so can easily call from command line.
        function! NextColor(how)
          call s:NextColor(a:how, 1)
        endfunction

        " Helper function for NextColor(), allows echoing of the color name to be
        " disabled.
        function! s:NextColor(how, echo_color)
          if len(s:mycolors) == 0
            call s:SetColors('all')
          endif
          if exists('g:colors_name')
            let current = index(s:mycolors, g:colors_name)
          else
            let current = -1
          endif
          let missing = []
          let how = a:how
          for i in range(len(s:mycolors))
            if how == 0
              let current = localtime() % len(s:mycolors)
              let how = 1  " in case random color does not exist
            else
              let current += how
              if !(0 <= current && current < len(s:mycolors))
                let current = (how>0 ? 0 : len(s:mycolors)-1)
              endif
            endif
            try
              execute 'colorscheme '.s:mycolors[current]
              break
            catch /E185:/
              call add(missing, s:mycolors[current])
            endtry
          endfor
          redraw
          if len(missing) > 0
            echo 'Error: colorscheme not found:' join(missing)
          endif
          if (a:echo_color)
            echo g:colors_name
          endif
        endfunction

        nnoremap <F8> :call NextColor(1)<CR>
        nnoremap <S-F8> :call NextColor(-1)<CR>
        nnoremap <A-F8> :call NextColor(0)<CR>

    "}}}
"}

" Formatting, Syntax {
    if has("syntax")
      syntax on
    endif

    au BufRead,BufNewFile *.php set ft=php.html

    "set list listchars=eol:⌟
    set wrap " Do not wrap long lines
    set smartindent " Indent at the same level of the previous line
    set shiftwidth=4 " Use indents of 4 spaces
    set expandtab " Tabs are spaces, not tabs
    set tabstop=4 " An indentation every four columns
    set softtabstop=4 " Let backspace delete indent
    set nojoinspaces " Prevents inserting two spaces after punctuation on a join (J)
    set splitright " Puts new vsplit windows to the right of the current
    set splitbelow " Puts new split windows to the bottom of the current
    "set matchpairs+=<:> " Match, to be used with %
    "set comments=sl:/*,mb:*,elx:*/ " auto format comment blocks
    " Remove trailing whitespaces and ^M chars
    " To disable the stripping of whitespace, add the following to your
    " .vimrc.before.local file:
    " let g:spf13_keep_trailing_whitespace = 1
    function! ToggleSyntax()
       if exists("g:syntax_on")
          syntax off
       else
          syntax enable
       endif
    endfunction
" }

" Search and highlight {
    set ignorecase      " Case insensitive search
    set smartcase       " Case sensitive when uc present
    set incsearch       " Find as you type search
    set hlsearch        " Highlight search terms
" }

" Remappings, Hotkeys, Macros {

    let mapleader = "\<Space>"

    " gs = git-status
    nmap <leader>gs :Gstatus<CR><C-W>15+

    nmap <leader><leader> V

    " jump between buffers
    nnoremap gb :ls<CR>:b<Space>

    " save with S = :w<cr>
    nnoremap S :w<CR>

    " escape is 'jk' in insert mode
    imap jk <esc>

    " switch buffers with F2
    map <F2> :bnext<CR>
    map <S-F2> :bprev<CR>

    " switch tab with F3
    map <F3> gt<CR>
    map <S-F3> gT<CR>

    " more tab commands with t*
    nnoremap tn :tabnew<Space>
    nnoremap tk :tabnext<CR>
    nnoremap tj :tabprevious<CR>
    nnoremap th :tabfirst<CR>
    nnoremap tl :tablast<CR>

    nmap <silent> <leader>s :call ToggleSyntax()<CR>
    
    " Function keys
    set pastetoggle=<F12> " pastetoggle (sane indentation on pastes)

    " Folding
    inoremap <F9> <C-O>za
    nnoremap <F9> za
    onoremap <F9> <C-C>za
    vnoremap <F9> zf

" }

filetype plugin on
