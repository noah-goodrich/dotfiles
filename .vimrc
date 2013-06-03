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
Bundle 'ervandew/supertab'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kien/ctrlp.vim'
Bundle 'tomasr/molokai'
Bundle 'wavded/vim-stylus'
Bundle 'noahfrederick/Hemisu'
Bundle 'tpope/vim-fugitive'
Bundle 'nono/vim-handlebars'
Bundle 'tpope/vim-obsession'
Bundle 'joonty/myvim'
Bundle 'shawncplus/phpcomplete.vim'
Bundle 'flazz/vim-colorschemes'

if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif

" per instructions for markdown
let g:vim_markdown_folding_disabled=1

" vim-scripts repos don't need username
Bundle 'nginx.vim'
Bundle 'bclear'

filetype plugin indent on       " load file type plugins + indentation
set showcmd                     " display incomplete commands

" make copy paste work with tmux
set clipboard=unnamed
" Color stuff
set background=dark

" Gutter
set number
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

" CoffeeScript compilation
" Compile a highlighted section of code
vmap <leader>c <esc>:'<,'>:CoffeeCompile<CR>
" Compile the entire file if nothing is highlighted
map <leader>c :CoffeeCompile<CR>

" compile the whole coffeescript file and jump to a line
" useful for debugging stack traces
" Run with :C [line_number]
command -nargs=1 C CoffeeCompile | :<args>


" Plugin Setup
" ********************

" Setup ctrlp.vim
" Ignore version control and binary files
let g:ctrlp_custom_ignore = {
  \ 'dir': '\.git$\|\.hg$\|\.svn$\|node_modules$',
  \ 'file': '\.o$\|\.exe$\|\.bin$'
  \ }


au FileType python setlocal softtabstop=4 tabstop=4 shiftwidth=4 textwidth=0
au FileType go setlocal softtabstop=4 tabstop=4 shiftwidth=4 textwidth=0
au Filetype javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" Automatically call gofmt on golang files when saving as per
" http://stackoverflow.com/questions/10969366/vim-automatically-formatting-golang-source-code-when-saving
au FileType go au BufWritePre <buffer> Fmt

" .json files are javascript
au BufRead,BufNewFile *.json set ft=javascript

" These are all actually ruby files
au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,config.ru,*.gemspec} set ft=ruby

au BufRead,BufNewFile *.java set ft=java

au BufRead,BufNewFile *.php set ft=php

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
