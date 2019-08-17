let &viewdir=expand("$HOME") . "/.vim/views"
if !isdirectory(expand(&viewdir))|call mkdir(expand(&viewdir), "p", 451)|endif

set nocompatible
syntax enable
set encoding=utf-8
filetype off " required for vundle

" Setting up Vundle - the vim plugin bundler
    let iCanHazVundle=1
    let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
    if !filereadable(vundle_readme)
        echo "Installing Vundle.."
        echo ""
        silent !mkdir -p ~/.vim/bundle
        silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
        let iCanHazVundle=0
    endif
    set rtp+=~/.vim/bundle/vundle/
    call vundle#rc()
    Bundle 'gmarik/vundle'
"...All your other bundles...
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/nerdcommenter'
Bundle 'tpope/vim-surround'
Bundle 'hallison/vim-markdown'
Bundle 'pangloss/vim-javascript'
Bundle 'mileszs/ack.vim'
"Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-obsession'
Bundle 'scrooloose/syntastic'
Bundle 'shawncplus/phpcomplete.vim'
Bundle 'flazz/vim-colorschemes'
Bundle 'altercation/vim-colors-solarized'
Plugin 'NLKNguyen/pipe.vim' "required
Plugin 'NLKNguyen/pipe-mysql.vim'
Plugin 'elixir-editors/vim-elixir'

" vim-scripts repos don't need username
Bundle 'ScrollColors'
Bundle 'nginx.vim'
Bundle 'bclear'
Bundle 'vim-scripts/SQLComplete.vim'

if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif

" per instructions for markdown
let g:vim_markdown_folding_disabled=1

filetype plugin indent on       " load file type plugins + indentation
set showcmd                     " display incomplete commands

" make copy paste work with tmux
set clipboard=unnamed

" Color stuff
set background=dark

" Gutter
set number
set relativenumber
set cursorline

" Show a vertical line at 120 characters
if exists('+colorcolumn')
  set cc=120
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)
endif

" Allow background buffers without writing to them,
" and save marks/undo for background buffers.
set hidden

" Whitespace
set nowrap                      " don't wrap lines
set tabstop=4                   " a tab is two spaces
set shiftwidth=4
set softtabstop=4
set expandtab                   " use spaces, not tabs
set backspace=indent,eol,start  " backspace through everything in insert mode
set smartindent

" How to display tabs, trailing whitespace, and lines that extend to left of screen
set listchars=tab:\ \ ,trail:·,extends:>,precedes:\<
set list

" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set smartcase                   " ... unless they contain at least one capital letter

" Store swapfiles and backup files in .vim/tmp
silent execute '!mkdir -p "'.$HOME.'/.vim/tmp"'
"silent execute '!rm "'.$HOME.'/.vim/tmp/*"'
set backupdir=$HOME/.vim/tmp//
set directory=$HOME/.vim/tmp//

" statusline
" see :help statusline for more info on these options
" always show status line
set laststatus=2
set statusline=file:%f " filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, " file encoding
set statusline+=%{&ff}] " file format
set statusline+=%m " modified flag
set statusline+=%y " file type
set statusline+=%= " separator between right and left items
set statusline+=%{StatusLineFileSize()} " number of bytes or K in file
set statusline+=%l/%L " current line / total lines
set statusline+=\ %P " percentage through file

set viminfo='100,f1

function! StatusLineFileSize()
  let size = getfsize(expand('%%:p'))
  if (size < 1024)
    return size . 'b '
  else
    let size = size / 1024
    return size . 'k '
  endif
endfunction

" Mappings
let mapleader="," " use , for leader instead of backslash
" use jj for esc
inoremap jj <esc>
" use leader leader to jump to the previously edited file
nnoremap <leader><leader> <C-^>

" use leader w to enter window mode
noremap <space> <C-w>

" jump back and forth between previous panes
nnoremap <leader>p <C-W><C-P>

" toggle paste mode off and on
nnoremap <leader>o :set paste!<CR>

" Easier opening and closing of nerdtree
nnoremap <leader>t :NERDTreeToggle<CR>

" Eliminate all trailing whitespace
nnoremap <leader>w :%s/\s\+$//e<CR>

" clear search buffer when hitting return, so what you search for is not
" highlighted anymore. From Gary Bernhardt of Destroy All Software
nnoremap <CR> :nohlsearch<cr>

" semicolon is useless but SHIFT+; is annoying to do all the time
noremap ; :

" ScrollColors Mappings
map <silent><F3> :NEXTCOLOR<cr>
map <silent><F2> :PREVCOLOR<cr>

" Plugin Setup
" ********************

" Setup ctrlp.vim
" Ignore version control and binary files
let g:ctrlp_custom_ignore = {
  \ 'dir': '\.git$\|\.hg$\|\.svn$\|node_modules$',
  \ 'file': '\.o$\|\.exe$\|\.bin$'
  \ }


au FileType python setlocal softtabstop=4 tabstop=4 shiftwidth=4 textwidth=0 foldmethod=indent
au FileType go setlocal softtabstop=4 tabstop=4 shiftwidth=4 textwidth=0
au Filetype javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2
au FileType php setlocal tabstop=4 shiftwidth=4 softtabstop=4
au FileType mysql setlocal tabstop=4 shiftwidth=4 softtabstop=4 foldmethod=marker foldmarker=##-#,#-##

" Automatically call gofmt on golang files when saving as per
" http://stackoverflow.com/questions/10969366/vim-automatically-formatting-golang-source-code-when-saving
au FileType go au BufWritePre <buffer> Fmt

" .json files are javascript
au BufRead,BufNewFile *.json set ft=javascript

" These are all actually ruby files
au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,config.ru,*.gemspec} set ft=ruby

au BufRead,BufNewFile *.java set ft=java

au BufRead,BufNewFile *.php set ft=php

au BufRead,BufNewFile *.sql set ft=mysql

au BufWrite * mkview
au BufNewFile,BufRead * silent loadview

" Automatic Code Folding
set foldmethod=syntax
set foldlevelstart=1

let javaScript_fold=1         " JavaScript
let perl_fold=1               " Perl
let php_folding=1             " PHP
let sh_fold_enabled=1         " sh
let vimsyn_folding='af'       " Vim script
let xml_syntax_folding=1      " XML

" mysql-pipe config setup
let g:pipemysql_login_info = [
            \ {
            \                    'description' : 'local',
            \                    'mysql_hostname' : '0.0.0.0',
            \                    'mysql_username' : 'root',
            \                    'mysql_password' : '',
            \                   'mysql_database' : 'bluesun'
            \ },
            \ {
            \   'description' : 'bi1',
            \   'ssh_address' : 'noah@bi1-lendio.net',
            \   'mysql_hostname' : '127.0.0.1',
            \   'mysql_username' : '',
            \   'mysql_password' : '!'
            \ }
            \ ]"
