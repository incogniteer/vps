#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail
set +o histexpand

check_user() {
    if [[ $EUID != 0 ]]; then
        echo "Please run as root."
    fi
}

# 卸载旧版vim
remove_vim() {
    old_vim=(
        vim
        gvim
        vimx
        vim-gtk
        vim-runtime
        vim-common
        vim-enhanced
        vim-filesystem
    )

    for pkg in ${old_vim[@]}; do
        rpm -q $pkg && yum -y autoremove $pkg || return 0
    done
}

# 安装依赖以及一些软件库
install_tools() {
    PKG=(
        gcc
        make
        ncurses
        ncurses-devel
        git
        ctags
        tcl-devel
        ruby
        ruby-devel
        lua
        lua-devel
        luajit
        luajit-devel
        perl
        perl-devel
        perl-ExtUtils-ParseXS
        perl-ExtUtils-XSpp
        perl-ExtUtils-CBuilder
        perl-ExtUtils-Embed
        python3
        python3-devel
    )

    for pkg in ${PKG[@]}; do
    # 后面加true，才确保set -e继续执行
        ! rpm -q $pkg && yum -y install $pkg || true
    done
}

install_vim() {
    cd /usr/local/src
    git clone https://github.com/vim/vim.git
    cd vim

    ./configure --with-features=huge \
                --enable-multibyte \
                --enable-rubyinterp \
                --enable-pythoninterp \
                --enable-perlinterp \
                --enable-luainterp \
                --enable-gui=gtk2 \
                --enable-cscope \
                --with-python-config-dir=/lib64/python2.7/config \
                --prefix=/usr/local \
    # Debian推荐checkinstall
    #make && make checkinstall
    make && make install
    echo "Built success!"
}

# vim8以上版本利用内置包管理器安装插件
# :help packages
install_plugins() {
    # Indentation Guide
    sudo -u ${LUSER} \
    git clone https://github.com/Yggdroot/indentLine.git \
        /home/${LUSER}/.vim/pack/vendors/start/indentline
    # 生成帮助文档
    vim -u NONE \
        -c "helptags  ~/.vim/pack/vendor/start/indentline/doc" \
        -c "q"

    # badwolf colorscheme
    sudo -u ${LUSER} \
    git clone https://github.com/sjl/badwolf.git \
        /home/${LUSER}/.vim/pack/vendors/start/badwolf

    # solarized colorscheme
    sudo -u ${LUSER} \
    git https://github.com/altercation/vim-colors-solarized.git \
        /home/${LUSER}/.vim/pack/vendors/start/solarized
}

#Global vim configs
config_vim() {
local -r VIMRC=/home/${LUSER}/.vimrc
cat >> ${VIMRC} << \EOF
" 不跟vi兼容，防止命令出错
set nocompatible

" help force plugins to load correctly when it is turned back on below
filetype off

" 兼容windows，gvim
let s:is_win = has('win32')
if s:is_win
  set shell=cmd.exe
  set shellcmdflag=/c
  set guifont=Courier_New:h12
  set clipboard=unnamed
  behave xterm " mouse behave as unix
  language en_US.utf8 " en_US.utf8: output of locale -a
  " put pathogen.vim in ~\vimfiles\autoload
  "execute pathogent#infect()
  "execute pathogen#infect('bundle/{}', '/etc/vim/pathogen-bundles/{}')
  colorscheme torte
  " windowss内置插件设置方法，$HOME/vimfiles/pack/{plugins}/start,opt/badwolf
  "colorscheme badwolf
else
  " optional declaration, required for fish shell
  " 设置vim shell允许运行bash 函数，别名
  set shell=/bin/bash
  "set shell=/bin/bash
  " 运行完命令会导致vim stopped
  " only one process group can own the terminal
  " -i is interactive mode, it will set up its own process group
  set clipboard=unnamedplus
  set guifont=Source\ Code\ Pro\ 12
  set term=xterm-256color
  set langmenu=en_US.uft-8
  " pathogen runtime path manipulation, default: ~/.vim/autoload, ~/.vim/bundle
  " globally: put pathogen.vim at /usr/share/vim/vimfiles/autoload
  " # means autoloading: loading codes until actually needed
  " pathogen#infect: looks for a file called autoload/pathogen.vim in ~/.vim
  "execute pathogen#infect('bundle/{}', '/etc/vim/pathogen-bundles/{}')
  " windows gvim不不用vundle设置
  " 颜色必须放在 vundle#end后否则提示找不到，或者手动复制到vim/colors
  "colorscheme solarized
  "colorscheme ron
  "colorscheme goodwolf
  "colorscheme badwolf
  colorscheme solarized8_high
  "colorscheme solarized8
endif

" terminal状态禁用鼠标
if has("gui_running")
  set mouse=a
else
  set mouse=
  set ttymouse=
endif

" solarized 个性化设置
set background=dark
let g:solarized_termcolors = 256

" radwolf选项设置
" Turn on CSS properties highlighting
let g:badwolf_css_props_highlight = 1

" Turn off HTML link underlining
let g:badwolf_html_link_underline = 0

" Make the gutters darker than the background.
" Determines whether the line number, sign column, and fold column are rendered darker than the normal background, or the same.
let g:badwolf_darkgutter = 1

" 根据检测到的文件类型加载plugin
filetype plugin indent on

" 默认UTF8编码，兼顾中文编码
set termencoding=utf-8
set encoding=utf-8
scriptencoding uft-8
" heuristical fileencodings
"set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set fileencoding=utf-8
set langmenu=en_US.utf-8

syntax on

" mappings
let mapleader=','
" leader增加延迟timeout
" C-U类似bash快捷键消除行首内容
"nmap <silent> <Leader> :<C-U>set timeoutlen=99999 ttimeoutlen=99999<CR><Leader>
nnoremap <silent> <Leader> :<C-U>set timeoutlen=2000 ttimeoutlen=2000<CR>:call feedkeys('<Leader>')<CR>

" 去除搜索高亮显示
nnoremap <leader><space> :nohlsearch<cr>
" 加载以及打开vimrc
nnoremap <leader>rr :source ~/.vimrc<cr>
nnoremap <c-o> :vnew ~/.vimrc<cr>
" window navigation
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <tab> <c-w>
nnoremap <tab><tab> <c-w><c-w>
" 保存，推出命令快捷键
nnoremap <c-x> :x<cr>
nnoremap <leader>x :x<cr>
nnoremap <c-q> :q!<cr>
nnoremap <leader>q :q!<cr>
nnoremap <c-s> :w<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>ww :w !sudo tee %<cr>
" ctrl-o switches to normal mode temporarily in insert mode
inoremap <c-s> <c-o>:w<return> 

" black hole register _: /dev/null of registers
" noremap x "_x " less convenient to transpose chars
" paste in visual mode without updating register default
vnoremap p "_dP
" 映射：到；提高效率, 但是可能会跟F f冲突
" nnoremap ; :
" vnoremap ; :

" z for vim redrawing
" z+ Redraws the file with the cursor at top of window and at first non-blank character of your line
" z- Redraws the file with the cursor at bottom of window and at first non-blank character of your 
" z. Redraws the file with the cursor at centre of window and at first non-blank character of your line.
" zt/z+enter Redraws file with the cursor at top of the window.
" zb/z- Redraws file with the cursor at bottom of the window
" zz/z. Redraws file with the cursor at centre of the windoedraws file with the cursor at centre of the window
" keep the cursor in the middle at all times
" nnoremap k kzz
" nnoremap j jzz
" nnoremap G Gzz
" nnoremap P Pzz
" nnoremap x xzz
" inoremap <esc> <esc>zz

" 静默执行命令后返回原屏幕, :redraw!
nnoremap <c-l> :redraw!<cr>
nnoremap <leader>r :redraw!<cr>

" 经常使用nbsp， u+00a0，可以添加快捷键
" vim 插入unicode字符： insert mode + ctrl+v + x + a b
" nsbp = ctrl + k + space + space
nnoremap <leader><space><space> i<c-v>xa0

" vim直接运行bash 函数
" 方法1: bash -c "函数名", 没有读取bashrc，只能是parent shell exported的函数
" 方法2: bash -ic "函数名", 读取bashrc
" 方法3: vimrc shell=/bin/bash\ --login ?
" 调用GCC函数编译当前文件， %:.表示相对当前工作目录路径(relative to current directory)
" vim默认是bash -c命令，不是login也不是interactive
" 设置全局set shell=bash\ -i 会导致vim进程停止
" LESS要加-R/-r否则ANSI ESCAPE CODE颜色不能准确显示
nnoremap <F12> :!gcc-vi %:p \|& less -R<cr>
nnoremap <leader>g :!gcc-vi %:p \|& less -R<cr>

" j，k滚动消除重影, 会很卡慎用
"nnoremap j j<c-l>
"nnoremap k k<c-l>

" vim插入unicode方法
" ctrl-v + decimal (0~255) nbsp=160   
" ctrl-v + x + hex(2digit) nsbp=xa0
" ctrl-v + u + 4digit nsbp=u00a0
" ctrl-v + U + 8digits nsbp=U000000a0
" avoid undesired effects while pasting, turn off autoindent after pasting
" ≡
set pastetoggle=<F3>

" vim digraph: ctrl + k
" Ye ¥, e>:ê, e: ë, e!: è, e,:é, Ct: ¢, Pd: £

set tabstop=4 " ts
set softtabstop=4 " sts
set expandtab " et
set shiftwidth=4 " sw
set shiftround " >> indents to next multiple of shiftwidth

" line breaking
" soft-wrap visually, not insert newline
set textwidth=0
set wrapmargin=0 
" nowrap display long lines as just one, have to scroll horizontally to see the entire line
set wrap
" wrap lines visually, i.e. the line is still one line of text, but Vim displays it on multiple lines
"set wrap
set linebreak " break by word rather than character
" set columns=80 " visual break for textwidth=0
" line breaks only happens in special symbols like, space, hyphen, not in words
" breat lines with same indentation
set breakindent 
set breakindentopt=min:40
set formatoptions=tqnj
set formatoptions-=t
" disable   automatic comment insertion in current session
set formatoptions-=cro " -= remove options
" disable   automatic comment insertion in all files & sessions
" fo-=c, fo-=r
autocmd FileType * setlocal formatoptions-=c formatoptions-=o formatoptions-=r
" t: auto-wrap text using textwidth, insert line breaks to make text wrap at the width set by textwidth
" c: auto-wrap comments using textwidth, insert current comment leader automatically
" r: automatically insert current comment leader after hitting <ENTER> in insert mode
" r: automatically insert current comment leader after hitting o or O in normal mode

" 切换toggle是否换行
function! ToggleLineBreak()
  if &wrap 
    set nowrap
    set formatoptions-=t
  else
    set wrap
    set formatoptions+=t
  endif
endfunction

nnoremap <leader>t :call ToggleLineBreak()<cr>

set cindent
set autoindent
set smartindent

" indent guides/indent lines
" 利用vim8的conceal功能提供虚线缩进提示，如果是tab缩进可以用:set list lcs=tab:\|\ (here is space)
" vim8及以上用内置的package管理扩展包:help packages
" git clone https://github.com/Yggdroot/indentLine.git ~/.vim/pack/vendor/start/indentLint
" vim -u NONE -c "helptags  ~/.vim/pack/vendor/start/indentLint/doc" -c "q"
" Yggdroot/indentLine 相关设置
" Change Character Color: indentLine will overwrite 'conceal' color with grey by default
" let g:indentLine_setColors = 0: If you want to highlight conceal color with your colorscheme, disable it
"let g:indentLine_color_term = 239
" change indent char
" let g:indentLine_char = 'c'¦, ┆, │, ⎸, or ▏,let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" disabled by default: let g:indentLine_enabled = 0
" :IndentLinesToggle toggles lines on and off
"nnoremap <leader>ii :call IndentLinesToggle()<cr>

set incsearch
" set hls
set hlsearch 

set cursorline
" only highlight the first 200 columns
set synmaxcol=200 

" 显示控制字符
"set list " show non-printable characters
" ==?: case-insensitive no matter what the user has set(:set ignorecase)
" ==#: case-sensitive no matter what the user has set(:set ignorecase)
if has('multi_byte') && &encoding ==# 'utf-8'

  let &listchars = 'tab:> ,extends:❯,precedes:❮,nbsp:±'
  let &showbreak = '↳ ' " sbr=
else
  let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
  "let &listchars = tab:..,trail:_,extends:>,precedes:<,nbsp:~ " ASCII compliant
  let &showbreak=+++\  " \ escape trailing space, clearer: ='+++ '
  "let &showbreak=>\, String to put at the start of lines that have been wrapped.
  "let &showbreak=\\  " ASCII-compliant
  "set listchars=eol:§,tab:¤›,extends:»,precedes:«,nbsp:‡
  "listchars=tab:»·,nbsp:+,trail:·,extends:→,precedes:
endif

" gui不同listchars
"if has('gui_running')
"  set list listchars=tab:▶‒,nbsp:∙,trail:∙,extends:▶,precedes:◀
"  let &showbreak = '↳'
"else
"  set list listchars=tab:>-,nbsp:.,trail:.,extends:>,precedes:<
"  let &showbreak = '^'
"endif

" 显示/隐藏特殊字符快捷键
function! ToggleListChars()
  if &list
    set list!
  else
    set list
  endif
endfunction

nnoremap <leader>l :call ToggleListChars()<cr>
nnoremap <F5> :call ToggleListChars()<cr>

" bonus from reddit
hi NonText ctermfg=red ctermbg=yellow guifg=#4a4a59
hi SpecialKey ctermfg=16 ctermbg=240 guifg=#4a4a59
"		
" 			         
" html文件2个空格缩进, 优先使用FileType
autocmd FileType html setlocal sts=2 ts=2 sw=2 expandtab
autocmd FileType php setlocal sts=2 ts=2 sw=2 expandtab
autocmd FileType python setlocal sts=2 ts=2 sw=2 expandtab
"autocmd FileType json setlocal sts=4 ts=4 sw=4 expandtab

" 另外的设置方法, 但是有些情况会出错
" autocmd BufRead,BufNewFile *.htm,*html setlocal tabstop=2 shiftwidth=2 softtabstop=2
" autocmd BufRead,BufNewFile *.py setlocal tabstop=2 shiftwidth=2 softtabstop=2

" nginx syntax highlight
" copy vim/contrib to ~/.vim/syntax
au BufRead,BufNewFile *.nginx set ft=nginx
au BufRead,BufNewFile */etc/nginx/* set ft=nginx
au BufRead,BufNewFile */usr/local/nginx/conf/* set ft=nginx
au BufRead,BufNewFile nginx.conf set ft=nginx

" 临时文件统一管理, 需要手动创建子目录backup,swap等
" create direcotory if needed
if !isdirectory($HOME.'/.vim') && exists('*mkdir')
  call mkdir($HOME.'/.vim')
endif

" 确保目录存在不然不会报错
function! EnsureDirectoryExists(dir)
  if !isdirectory(a:dir)
    " exists({expr}): *funcname: builtin/user-defined function
    if exists("*mkdir")
      "call: call function
      " p: make intermediate directories as needed
      call mkdir(a:dir, 'p')
      "echo "Created directory: " . a:dir
    else
      echo "Please create directory: " . a:dir
    endif
  endif
endfunction

" 临时文件目录统一归类管理
" backup files
set backup
call EnsureDirectoryExists($HOME . '/.vim/backup')
set backupdir=$HOME/.vim/backup/
set backupext=-vimbackup
" skip make backups, default on unix, "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*"
set backupskip= 

" swap files
set swapfile
call EnsureDirectoryExists($HOME . '/.vim/swap')
set directory=$HOME/.vim/swap//
set updatecount=100

" undo files
set undofile
call EnsureDirectoryExists($HOME . '/.vim/undo')
set undodir=$HOME/.vim/undo/

" viminfo files
set viminfo='100,n$HOME/.vim/viminfo

" 显示设置, 确保支持256颜色
set t_Co=256
set number
set laststatus=2 " ls, always show status line, 0 never show
" set last status line content, backslash for escaping whitespace
set statusline=%F%r\ [HEX=%B]\ [%l,\ %v,\ %P]\ %{strftime(\"%H:%M\")}
" 当前window修改状态栏颜色
"highlight StatusLine cterm=bold ctermfg=black ctermbg=yellow
highlight StatusLineNC cterm=none ctermfg=255 ctermbg=0
"hi StatusLine ctermfg=14 ctermbg=239 guifg=#ffffff guibg=#4e4e4e cterm=bold gui=bold
"hi StatusLineNC ctermfg=249 ctermbg=237 guifg=#b2b2b2 guibg=#3a3a3a cterm=none gui=none
" StatusLineNC = not current window
" Manually set statusline color
"hi StatusLineTerm ctermbg=24 ctermfg=254 guibg=#004f87 guifg=#e4e4e4
"hi StatusLineTermNC ctermbg=252 ctermfg=238 guibg=#d0d0d0 guifg=#444444

set showmatch
" 修改showmatch 匹配括号的背景色, change highlighting background color of matching brackets/parentheses, braces 
" cterm: color term? determines styles: none, underline, bold
" ctermfg, ctermbg: determines foreground/background colors
" { {   } } ( ( ) ) [ [ ]    ]
hi MatchParen cterm=none ctermbg=green ctermfg=blue
set display=lastline " show as much as possible of last line
set showmode " show current mode in command-line
set showcmd " sc, show already typed keys when more expected
set wildmenu " tab completion with full matches
set wildmode=longest:list,full " first full list, then cyle through
" set colorscheme=ron

" scrolloff=scroll offset: number of context lines below/above the cursor you can see
" set scrolloff=5 set so=5: always 5 lines visible above cursor and below cursor, set so=0 restore normal behavior
" 快捷键切换当前行是否居中
nnoremap <leader>zz :let &scrolloff=999-&scrolloff<cr>

" select just pasted(last changed) text
nnoremap gp `[v`]
" more elaborate alternative
"nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" misc setting
set backspace=indent,eol,start " bs, make backspace work as you expect
" set hid, switch between buffers without having to save first
set hidden 
set splitbelow " open new window below the current window
set splitright " open new window right to the current window
set ttyfast " faster redrawing
" lazyredraw可能会出问题，频繁滚动屏幕你会出现重影乱码需要手动redraw！或者CTRL-l <C-L>
set nolazyredraw " lz, nolz, only redraw when necessary
set wrapscan " searches wrap around end-of-file
set noerrorbells
set visualbell
set ruler " ru, show line and column number of cursor
set ignorecase
set smartcase " only on when ignorecase on
set history=1000
set report=0 " always report changed line
set timeoutlen=1000 " for key mapping
set ttimeoutlen=0 " for key code delay
" file monitoring, same files being edited will show prompts
set autoread
" spell checking for english words
" set spelllang=en_us

set foldenable " enable folding
set foldlevelstart=10 " open most folds by default
set foldnestmax=10 " 10 nested folds ma=x
set foldmethod=indent " fold based on indent level

" 监听vim配置文件，保存buffer后重新加载
let $vimrc = '~/.vimrc'
let $gvimrc = '/etc/vim/vimrc'
let $gui_vimrc = '~/.gvimrc'
let $gui_gvimrc = '/etc/vim/gvimrc'
augroup vimrc 
  " au! remove autocmd in this group, instead of all autocmd
  au! BufWritePost *vimrc,vimrc.local so $vimrc | if exists($gvimrc) | so $gvimrc | endif | redraw
  au! BufWritePost *gvimrc if has('gui_running') && exists($gui_vimrc) | so $gui_vimrc | endif | redraw
augroup END

" 突出当前窗口背景
augroup windowHighlight 
  autocmd!
  autocmd WinEnter * hi LineNr ctermfg=247 guifg=#9e9e9e ctermbg=233 guibg=#121212
  autocmd WinLeave * hi LineNr ctermfg=274 guifg=#e9e9e9 ctermbg=133 guibg=#212121
augroup END

" vim全屏状态下至少在wsl会出现重影，用autocmd结合focusgained事件，每次强重画屏幕
autocmd FocusGained * redraw!

" norm[al][!] execute normal mode command [!] disable mapping
" exe[cute] {expr} execute command concated from expr evaluation
" g`{mark} g'{mark} go to the mark's position
" line() return the line#, eg, :echo line(".")
if has('autocmd')
  " 重新打开vim文件，记住上次保存的位置
  " Don't do it when the position is invalid or when inside event handler
  " Also don't do it when the mark in the first line, which is default
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \  exe "normal! g`\"" |
        \ endif
endif

"""
" turnoff autoindent
"set nocindent
"set nosmartindent
"set noautoindent
"set indentexpr=
"filetype indent off
"filetype plugin indent off" 
"""

" 下面设置覆盖创建以及全局设置的一些选项
"hi MatchParen cterm=none ctermfg=blue ctermbg=green

"Normal ctermfg=15 ctermbg=233 guifg=#f8f6f2 guibg=#1c1b1a
hi NonText cterm=none ctermfg=15 ctermbg=233 guifg=#f8f6f2 guibg=#1c1b1a

"hi NonText term=none ctermfg=9 ctermbg=11 gui=bold guifg=#4a4a59 guibg=bg
"hi NonText ctermbg=blue

" badwolf 颜色控制代码
" nontext 控制无文字区域颜色默认是亮黄色
" hi normal ctermbg 控制文字背景色
" set background 并不能改变背景颜色，Setting this option does not change the background color, it tells Vim what the background color looks like.
" All of the Gravel colors are based on a brown from Clouds Midnight.
"let s:bwc.brightgravel   = ['d9cec3', 252]
"let s:bwc.lightgravel    = ['998f84', 245]
"let s:bwc.gravel         = ['857f78', 243]
"let s:bwc.mediumgravel   = ['666462', 241]
"let s:bwc.deepgravel     = ['45413b', 238]
"let s:bwc.deepergravel   = ['35322d', 236]
"let s:bwc.darkgravel     = ['242321', 235]
"let s:bwc.blackgravel    = ['1c1b1a', 233]
"let s:bwc.blackestgravel = ['141413', 232]

" 修改一下几个行可以控制颜色
" 建议在~/.vimrc修改
"call s:HL('Normal', 'plain', 'blackgravel') 
"call s:HL('MatchParen', 'dalespale', 'darkgravel', 'bold')
"call s:HL('NonText',    'deepgravel', 'bg')
"call s:HL('SpecialKey', 'deepgravel', 'bg')

" vim indentline cpu很高可以尝试用这个选项
" indentLine_faster = 1 deprecated now
"let g:indentLine_faster = 1
let g:indentLine_newVersion=0

EOF

# 修改正确权限跟所有权
# 也可以用sudo -u ${USER} bash -c "cat ..."
chown ${LUSER}:${LUSER} ${VIMRC}
chmod 664  ${VIMRC}

echo "Configs set up success!"

}

# 卸载编译vim
uninstall_vim() {
    # 切换到vim源文件路径
    cd /usr/local/src/vim

    # debian可以用checkinstall跟彻底
    #make checkinstall unistall
    make uninstall
}

root_install_plugins() {
    # Indentation Guide
    git clone https://github.com/Yggdroot/indentLine.git \
        /root/.vim/pack/vendors/start/indentline
    # 生成帮助文档
    vim -u NONE \
        -c "helptags  ~/.vim/pack/vendor/start/indentline/doc" \
        -c "q"

    # badwolf colorscheme
    git clone https://github.com/sjl/badwolf.git \
        /root/.vim/pack/vendors/start/badwolf

    # solarized colorscheme
    git https://github.com/altercation/vim-colors-solarized.git \
        /root/.vim/pack/vendors/start/solarized
}

root_config_vim() {
    cp /home/${LUSER}/.vimrc /root/.vimrc
}

main() {
    LUSER=incognito  # 安装用户名
    check_user
    remove_vim
    install_tools
    install_vim
    install_plugins
    config_vim
    root_install_plugins
    root_config_vim
}

main && echo "Vim installed success!"
