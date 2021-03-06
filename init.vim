"==========================================================
" Startup-only commands
"==========================================================
if has('vim_starting')
  set encoding=utf-8
  scriptencoding=utf-8

  let g:kzsh#vim_dir = expand('$VIM_DIR')
  let g:kzsh#vim_tmp_dir = g:kzsh#vim_dir . '/.tmp'
  let g:kzsh#vim_undo_dir = g:kzsh#vim_tmp_dir . '/undo//'
  let g:kzsh#vim_log_dir = '/tmp/neovim'
  call mkdir(g:kzsh#vim_log_dir, 'p')

  " ----------------------------------------------------------------------------
  " Python Venv
  " ----------------------------------------------------------------------------
  " Python 3
  let s:pyenv_python3 = glob(expand('$PYENV_ROOT/versions/neovim3/bin/python'))
  if executable(s:pyenv_python3)
    let g:python3_host_prog = s:pyenv_python3
  else
    let g:loaded_python3_provider = 1
  endif

  " Python 2
  let s:pyenv_python2 = glob(expand('$PYENV_ROOT/versions/neovim2/bin/python'))
  if executable(s:pyenv_python2)
    let g:python_host_prog  = s:pyenv_python2
  else
    let g:loaded_python_provider = 1
  endif

  " Ruby
  let s:ruby_host_prog = glob(expand('$HOME/.rbenv/versions/2.4.5/bin/neovim-ruby-host'))
  if executable(s:ruby_host_prog)
    let g:ruby_host_prog  = s:ruby_host_prog
  else
    let g:loaded_ruby_provider = 1
  endif

  " Core Configuration
  " ----------------------------------------------------------------------------
  let g:mapleader = "\<Space>"

  if executable('rg')
    " set grepprg=rg\ --vimgrep\ --no-heading
    set grepprg="rg --column --colors path:fg:blue --line-number --no-heading --color=always --smart-case"
    set grepformat=%f:%l:%c:%m,%f:%l:%m
  endif

  " Runtime Behavior
  " ----------------------------------------------------------------------------
  let g:path='.,**,,'
  set path=g:path
  set suffixesadd=.js,.jsx,.ts,.tsx


  " let g:source_cache = expand("/tmp/github/")
  let g:source_cache = expand("$HOME/src/github/")
  function! LoadMainNodeModule(fname)
    let sourcePackageJsonPath = g:source_cache . a:fname . "/package.json"

    if filereadable(l:sourcePackageJsonPath)
      return l:sourcePackageJsonPath
    endif

    let nodeModules = FindGitRoot() . "/./node_modules/"
    let packageJsonPath = l:nodeModules . a:fname . "/package.json"

    echo l:packageJsonPath
    if filereadable(packageJsonPath)
      let github_url = json_decode(join(readfile(packageJsonPath))).repository.url
      let normalized_url = substitute(l:github_url, "git+", "", "")

      execute('!git clone ' . l:normalized_url. ' ' . g:source_cache . a:fname)

      if filereadable(l:sourcePackageJsonPath)
        return l:sourcePackageJsonPath
      else
        return packageJsonPath
      endif
    endif

    return nodeModules . a:fname
  endfunction

  autocmd BufEnter *.ts setlocal includeexpr=LoadMainNodeModule(v:fname)
  autocmd BufEnter *.js setlocal includeexpr=LoadMainNodeModule(v:fname)
  autocmd BufEnter *.tsx setlocal includeexpr=LoadMainNodeModule(v:fname)
  autocmd BufEnter *.jsx setlocal includeexpr=LoadMainNodeModule(v:fname)

  set nomodeline

  set lazyredraw " Prevent UI from drawing during macro execution.
  set laststatus=1
  set showcmd
  set noshowmode
  set noerrorbells
  set shortmess+=rsI
  set regexpengine=1 " set regex engine
  set autoread
  set hidden " only hide buffers, to preserve undo history when returning to other buffers
  set scrolloff=8
  set sidescrolloff=5
  set list " draw whitespace
  set listchars=tab:>-,trail:~,extends:>,precedes:<
  set hlsearch " highlight matches
  set incsearch " start searching as text is entered

  " set timeout when looking for key combinations
  set notimeout
  set nottimeout
  set ttimeoutlen=0

  " Turn off swap files
  set noswapfile
  set nobackup
  set nowritebackup

  set updatetime=10

  " Use system clipboard
  set clipboard=unnamed
  set clipboard+=unnamedplus

  if has('nvim')
    set mouse=""
  endif

  " Allow shell commands to use globbing like **/*.foo
  set shell+=\ -O\ globstar

  for s:rpc_plugin in globpath(g:kzsh#vim_dir . '/rpc-plugins', '*', 0, 1)
    if (isdirectory(s:rpc_plugin))
      for s:plugin in globpath(s:rpc_plugin, '*', 0, 1)
        let &runtimepath.=','.s:plugin
      endfor
    endif
  endfor

  " Syntax
  " ----------------------------------------------------------------------------
  filetype plugin indent on

  " Display
  " ----------------------------------------------------------------------------
  set number " display line numbers
  set showbreak=↪\
  syntax enable
  set synmaxcol=512 " syntax highlight long lines
  augroup SyncSyntaxFromStart
    autocmd BufEnter * :syntax sync fromstart
  augroup END
  set splitright
  set signcolumn=yes

  " Navigation
  " ----------------------------------------------------------------------------
  set backspace=indent,eol,start " backspace will traverse indent, eol, start

  " Formatting
  " ----------------------------------------------------------------------------
  set smartindent
  set autoindent
  set tabstop=2
  set shiftwidth=2
  set expandtab
  set foldmethod=syntax
  set foldlevelstart=1
  set nofoldenable
  set formatoptions=qrn1j
  set shiftround

  " Autocomplete
  " ----------------------------------------------------------------------------
  set wildmenu
  set wildmode=longest:full,full
  set wildignore+=*.git,*.hg,*.svn,*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
  set complete=.,w,b,u,t,i
  set completeopt=longest,menuone,preview

  " undo files
  " double slash means create dir structure to mirror file's path
  set undofile
  set undolevels=1000
  set undoreload=10000

  let &undodir=g:kzsh#vim_undo_dir

  "==========================================================
  " Yardoc customizations
  "==========================================================
  hi link yardGenericTag rubyInstanceVariable

  "override statusline
  " hi StatusLine ctermbg=236 ctermfg=254
  " hi StatusLineNC ctermbg=236 ctermfg=254
  " hi VertSplit ctermbg=236 ctermfg=254
  " hi NeomakeErrorMsg ctermfg=161 ctermbg=236
  " hi NeomakeWarningMsg ctermfg=230 ctermbg=236
endif

"==========================================================
" Load Plugins
"==========================================================
call plug#begin('~/.config/nvim/lib')


Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'rhysd/reply.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neco-syntax', { 'for': ['javascript', 'javascript.jsx' ] }
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'airblade/vim-gitgutter'
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next' }
Plug 'chazy/dirsettings'
Plug 'darfink/vim-plist', { 'for': 'plist' }
Plug 'dkarter/bullets.vim', { 'for': 'markdown' }
Plug 'dln/avro-vim', {'for': 'avdl' }
Plug 'duggiefresh/vim-easydir'
Plug 'godlygeek/tabular', {'for': 'cucumber' }
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }
Plug 'jparise/vim-graphql', { 'for': 'graphql'}
Plug 'jremmen/vim-ripgrep'
Plug 'junegunn/goyo.vim',
Plug 'kien/rainbow_parentheses.vim', { 'for': 'clojure' }
Plug 'kshenoy/vim-signature'
Plug 'kzsh/vim-chunkwm-navigator'
Plug 'lervag/vimtex', { 'for': 'tex' }
Plug 'lifepillar/pgsql.vim', { 'for': 'sql' }
Plug 'mattn/vim-xxdcursor'
Plug 'mitsuse/autocomplete-swift', { 'for': 'swift' }
Plug 'morhetz/gruvbox'
Plug 'noprompt/vim-yardoc', { 'for': 'ruby' }
Plug 'norcalli/nvim-colorizer.lua'
Plug 'plasticboy/vim-markdown', { 'for': ['markdown'] }
Plug 'jxnblk/vim-mdx-js', { 'for': 'markdown.mdx' }
Plug 'reasonml-editor/vim-reason-plus', { 'for': 'reason'}
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'racer-rust/vim-racer', { 'for': 'rust' }
Plug 'sirver/ultisnips'
Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-classpath', { 'for': 'clojure' }
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-cucumber', { 'for': 'cucumber' }
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git', { 'for': ['gitconfig', 'gituser', 'gitignore_global'] }
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'udalov/kotlin-vim', { 'for': 'kotlin' }
Plug 'dense-analysis/ale'
" Plug 'zchee/deoplete-jedi', { 'for': 'python' }

call plug#end()

"==========================================================
" configure omnicomplete settings
"==========================================================
" augroup CustomFileCompletionSettings
"   autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"   autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"   autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"   autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"   autocmd FileType c set omnifunc=ccomplete#Complete
" augroup END
set omnifunc=ale#completion#OmniFunc

"==========================================================
" Set terminal title (for use with chunkwm -- detecting a vim session)
"==========================================================
set title

" augroup VimSystemHook
"   autocmd BufEnter * call SetTerminalTitle()
" augroup END

" function! SetTerminalTitle()
"     let titleString = expand('%:t')
"     if len(titleString) > 0
"         let &titlestring = expand('%:t')
"         " this is the format iTerm2 expects when setting the window title
"         let args = "\033];vim_hook(".&titlestring.")\007"
"         " let cmd = 'silent !echo -e "'.args.'"'
"         execute cmd
"         redraw!
"     endif
" endfunction

" augroup VimSystemHook
"   autocmd BufEnter * let &titlestring = 'vim_hook(' . expand('%:t') . ')'
" augroup END

"==========================================================
" FileType-specific formatting
"==========================================================
autocmd BufRead,BufNewFile *.applescript setlocal filetype=applescript
autocmd BufRead,BufNewFile *.avdl        setlocal filetype=avdl
autocmd BufRead,BufNewFile Jenkinsfile*  setlocal filetype=groovy
autocmd BufRead,BufNewFile .babelrc      setlocal filetype=json
autocmd BufRead,BufNewFile .eslintrc     setlocal filetype=json
autocmd BufRead,BufNewFile .stylelintrc  setlocal filetype=json
autocmd BufRead,BufNewFile *.kt          setlocal filetype=kotlin
autocmd BufRead,BufNewFile *.kt          setlocal filetype=kotlin
autocmd BufRead,BufNewFile *.markdown    setlocal filetype=markdown
autocmd BufRead,BufNewFile *.md          setlocal filetype=markdown
autocmd BufRead,BufNewFile *.mkd         setlocal filetype=markdown
autocmd BufRead,BufNewFile *.jbuilder    setlocal filetype=ruby
autocmd BufRead,BufNewFile Podfile*      setlocal filetype=ruby
autocmd BufRead,BufNewFile Vagrantfile*  setlocal filetype=ruby
autocmd BufRead,BufNewFile .envrc        setlocal filetype=sh
autocmd BufRead,BufNewFile *.swift       setlocal filetype=swift
autocmd BufRead,BufNewFile *.ts          setlocal filetype=typescript
autocmd BufRead,BufNewFile *.tsx         setlocal filetype=typescript.tsx

" set Tabs per file-type.  (current unused, see above)
autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype css setlocal ts=2 sts=2 sw=2
autocmd Filetype tag setlocal ts=2 sts=2 sw=2
autocmd Filetype xml setlocal ts=2 sts=2 sw=2
autocmd Filetype jsp setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd Filetype m setlocal ts=4 sts=4 sw=4
autocmd Filetype h setlocal ts=4 sts=4 sw=4
autocmd Filetype wflow setlocal ts=4 sts=4 sw=4
autocmd Filetype plist setlocal ts=4 sts=4 sw=4
autocmd Filetype swift setlocal ts=2 sts=2 sw=2
autocmd Filetype applescript setlocal ts=4 sts=4 sw=4 noexpandtab
autocmd Filetype groovy setlocal ts=4 sts=4 sw=4
autocmd Filetype kotlin setlocal ts=4 sts=4 sw=4
autocmd Filetype markdown setlocal conceallevel=2
autocmd Filetype json setlocal conceallevel=0
autocmd Filetype gitconfig setlocal ts=2 sts=2 sw=2 noexpandtab

augroup ReturnToLastCursorPosition
  au BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif
augroup END

augroup WrapLineInFile
  autocmd!
  autocmd FileType markdown setlocal linebreak
  autocmd FileType markdown setlocal formatoptions+=t
  autocmd FileType markdown setlocal textwidth=120
augroup END

"==========================================================
" Set special char highlighting parames
"==========================================================
hi SpecialKey term=bold cterm=bold ctermfg=16 guifg=#000
hi NonText term=bold cterm=bold ctermfg=16 guifg=#000

"==========================================================
" Return to previous buffer with Tab
"==========================================================
nnoremap <special> <Tab> <C-^>

"==========================================================
" Swap backtic and single quote
"==========================================================
nnoremap ' `
nnoremap ` '

"==========================================================
" Add shortcut to edit init.vim/vimrc
"==========================================================
command! INIT tabedit $MYVIMRC

"==========================================================
" Typescript-Vim config
"==========================================================
let g:typescript_compiler_binary = ''

"==========================================================
" PGSql config
"==========================================================
let g:sql_type_default = 'pgsql'

"==========================================================
" Ale config
"==========================================================
let g:ale_fix_on_save = 1
let g:ale_fixers_explicit = 1
let g:ale_linters_explicit = 1
let g:ale_set_quickfix = 0
let g:ale_lint_delay = 600
let g:ale_disable_lsp = 1

" let g:ale_linters_ignore = {
"       \ 'typescript': ['tslint', 'tsserver'],
"       \ 'typescript.tsx': ['tslint', 'tsserver']
"       \}
" let g:ale_kotlin_languageserver_executable = '~/src/github/kotlin-language-server/server/build/install/server/bin/kotlin-language-server'

let g:ale_linters = {
  \ 'sh':  ['shellcheck'],
  \ 'typescript': ['eslint'],
  \ 'javascript': ['eslint'],
  \ 'kotlin': ['ktlint'],
  \ 'java': ['ktlint']
\}

let g:ale_fixers = {
\  'javascript':  ['prettier'],
\  'typescript':  ['prettier'],
\  'javascript.jsx':  ['prettier'],
\  'css':  ['stylelint'],
\  'typescript.tsx':  ['prettier'],
\  'json':  ['prettier'],
\  'kotlin': ['ktlint']
\}

let g:ale_pattern_options = {
\   'styles\.ts$': {
\       'ale_linters': ['stylelint'],
\   },
\}

"==========================================================
" vim-commentary Config
"==========================================================
augroup VimCommentaryAdditionalSyntaxes
  autocmd FileType handlebars setlocal commentstring={{!%s}}
augroup END

"==========================================================
" Emmet Config
"==========================================================
let g:user_emmet_leader_key='<C-E>'
let g:user_emmet_mode='a'

"==========================================================
" FZF Config
"==========================================================

" Currently replaced by a ripgrep plugin
" command! -bang -nargs=* Rg
"   \ call fzf#vim#grep(
"   \   'rg --column --colors path:fg:blue --line-number --no-heading --color=always --smart-case --files ' . expand(<q-args>), {'options': '--delimiter : --nth 4..'},
"   \   <bang>0 ? fzf#vim#with_preview('up:60%')
"   \           : fzf#vim#with_preview('right:50%:hidden', '?'),
"   \   <bang>0)

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

nnoremap <Leader>;; :Buffers<CR>
nnoremap <Leader>;f :FZF<CR>
nnoremap <Leader>;F :execute 'Files ' . expand('%:p:h')<CR>
nnoremap <Leader>;af :execute 'Files' FindGitRoot()<CR>
nnoremap <Leader>;cc :BCommits<CR>
nnoremap <Leader>;ca :Commits<CR>
nnoremap <Leader>;l :Lines<CR>
nnoremap <Leader>ff :Rg ''<Left>
nnoremap <Leader>FF :execute 'Find!' . expand('%:p:h') <CR>
nnoremap <Leader>fa :execute 'Rg' FindGitRoot()<CR>
nnoremap <Leader>fw :execute "Rg '\\b" . expand('<cword>') . "\\b' " . FindGitRoot()<CR>

command! -bang -nargs=* TestQArgs echo <q-args>


nnoremap <Leader>te :call fzf#run({'sink': 'tabedit'})<CR>
" nnoremap <Leader>t;; :tab new \| Buffers<CR>
" nnoremap <Leader>t;f :tab new \| FZF ./<CR>
" nnoremap <Leader>t;af :tab new \| execute 'Files' FindGitRoot()<CR>
" nnoremap <Leader>t;cc :BCommits<CR>
" nnoremap <Leader>t;ca :Commits<CR>
" nnoremap <Leader>t;l :Lines<CR>

let g:fzf_commits_log_options = "--color=always --pretty=format:'%C(green)%h%C(reset)%C(yellow)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)' --abbrev-commit"
let g:fzf_history_dir = g:kzsh#vim_tmp_dir . '/fzf-history//'

" let g:fzf_action = {
"   \ 'ctrl-alt-j': 'down',
"   \ 'ctrl-alt-k': 'up' }

"==========================================================
" neovim-snippet
"==========================================================
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
" imap <C-e>     <Plug>(neosnippet_expand_or_jump)
" smap <C-e>     <Plug>(neosnippet_expand_or_jump)
" xmap <C-e>     <Plug>(neosnippet_expand_target)

" let g:neosnippet#snippets_directory='~/.config/nvim/snippets'

" augroup NeoSnippetClearMarkers
"   autocmd InsertLeave * NeoSnippetClearMarkers
" augroup END

" For conceal markers.
" if has('conceal')
"   set conceallevel=2 concealcursor=niv
" endif


"==========================================================
" ultisnips
"==========================================================
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsSnippetDirectories=["ulti-snippets"]

"==========================================================
" Language Server configuration
"==========================================================

let g:LanguageClient_selectionUI = "location-list"
let g:LanguageClient_diagnosticsEnable = 1
let g:LanguageClient_diagnosticsDisplay = {
    \     1: {
    \         "name": "Error",
    \         "texthl": "ALEError",
    \         "signText": "✖",
    \         "signTexthl": "ALEeErrorSign",
    \         "virtualTexthl": "Error",
    \     },
    \     2: {
    \         "name": "Warning",
    \         "texthl": "ALEWarning",
    \         "signText": "⚠",
    \         "signTexthl": "ALEWarningSign",
    \         "virtualTexthl": "Warning"
    \     },
    \     3: {
    \         "name": "Information",
    \         "texthl": "ALEInfo",
    \         "signText": "ℹ",
    \         "signTexthl": "ALEInfoSign",
    \         "virtualTexthl": "Comment"
    \     },
    \     4: {
    \         "name": "Hint",
    \         "texthl": "ALEInfo",
    \         "signText": "➤",
    \         "signTexthl": "ALEInfoSign",
    \         "virtualTexthl": "Comment"
    \     },
    \ }

" let g:LanguageClient_rootMarkers = ['.git']
let g:LanguageClient_rootMarkers = {
         \ 'tsx': ['.git'],
         \ 'typescript': ['.git'],
         \ 'typescript.tsx': ['.git']
         \ }

nnoremap <Leader><Leader> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> <leader>k :call LanguageClient#explainErrorAtPoint()<CR>
nnoremap <silent> <leader>K :call LanguageClient#explainErrorAtPoint()<CR>
nnoremap <silent> <Leader>gi :call LanguageClient#textDocument_implementation()<CR>
nnoremap <silent> <Leader>gt :call LanguageClient#textDocument_typeDefinition()<CR>
nnoremap <silent> <Leader>gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <Leader>gf :call LanguageClient#textDocument_formatting()<CR>
" nnoremap <silent> <Leader>gr :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> <Leader>gr :call LanguageClient#textDocument_references()<CR>

nnoremap <silent> <Leader>ge :ALEDetail<CR>

function! LookUpDocs()
  try
    LanguageClient_contextMenu()
  catch /.*/
    try
      :Man
    catch /.*/
      normal! gd
    endtry
  endtry
endfunction

function! LookUpDefinition()
  try
    LanguageClient#textDocument_definition()
  catch /.*/
    try
    normal! gd
    try
      LanguageClient#textDocument_definition()
    catch /.*/
    endtry
    LanguageClient#textDocument_typeDefinition()<CR>
  endtry
  endtry
endfunction

nnoremap <Leader><Leader>r :LanguageClientStop<CR> :sleep 1<CR> :LanguageClientStart<CR>

 let g:LanguageClient_serverCommands = {
     \ 'ocaml': ['ocaml-language-server', '--stdio'],
     \ 'reason': ['ocaml-language-server', '--stdio'],
     \ 'kotlin': ["~/src/github/kotlin-language-server/server/build/install/server/bin/kotlin-language-server"],
     \ 'tsx': ['typescript-language-server', '--stdio', '--tsserver-path', expand('node_modules/.bin/tsserver')],
     \ 'typescript': ['typescript-language-server', '--stdio', '--tsserver-path', expand('node_modules/.bin/tsserver')],
     \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
     \ 'typescript.tsx': ['typescript-language-server', '--stdio', '--tsserver-path', expand('node_modules/.bin/tsserver')],
     \}

     " \ 'kotlin': ['~/src/github/tools/language-servers/KotlinLanguageServer/build/install/kotlin-language-server/bin/kotlin-language-server', 'tcp://127.0.0.1:8080'],

"==========================================================
" ReasonML Language Configurations
"==========================================================
augroup ReasonMLAutoFormat
  au!
  autocmd BufWritePre *.re call LanguageClient_textDocument_formatting() | sleep 100m | noautocmd w
augroup END


"==========================================================
" Rust Language Configurations
"==========================================================
augroup RustAutoFormat
  au!
  autocmd BufWritePre *.rs RustFmt
augroup END


"==========================================================
" Run Autocommit on TODO.md
"==========================================================
let g:todo_path = expand('~/TODO')
augroup autoCommitChangesToTODO
  au!
  " TODO: don't execute todo commit for any TODO.md file anywhere.
  autocmd BufWritePre TODO.md silent! execute('!' . g:todo_path . '/autocommit.sh')
augroup END

"==========================================================
" vim Markdown
"==========================================================
let g:markdown_fenced_languages = ['html', 'ruby', 'js=javascript', 'python', 'bash=sh', 'graphql', 'ts=typescript']

"==========================================================
" vimtex
"==========================================================
let g:tex_flavor='latex'
let g:vimtex_view_method='skim'
" let g:vimtex_view_method='zathura'
" let g:vimtex_view_general_viewer = 'zathura'
" let g:vimtex_view_general_viewer = '/Applications/Skim.app/open -a Skim'
let g:vimtex_quickfix_mode=0
set conceallevel=0
let g:tex_conceal='abdmg'

"==========================================================
" SQL Execute visual-selection
"==========================================================
let g:kzsh_sql_out_file = '/tmp/neovim-sql-out.sql'
let g:kzsh_sql_in_file = '/tmp/neovim-sql-in.sql'

augroup ExecuteSelectedTextByFileType
  autocmd FileType ruby       vnoremap <buffer> <Leader>rr :!cat \| awk '{ print "puts "$0 }' \| ruby<CR>
  autocmd FileType javascript vnoremap <buffer> <Leader>rr :!cat \| awk '{ print "process.stdout.write(String("$0"))" }' \| node<CR>
  autocmd FileType typescript vnoremap <buffer> <Leader>rr :!cat \| awk '{ print "process.stdout.write(String("$0"))" }' \| node<CR>
augroup END

"==========================================================
" Resize panes with arrow keys and shift
"==========================================================
nnoremap <Left> :vertical resize -1<CR>
nnoremap <Right> :vertical resize +1<CR>
nnoremap <Up> :resize -1<CR>
nnoremap <Down> :resize +1<CR>

nnoremap <S-Left> :vertical resize -10<CR>
nnoremap <S-Right> :vertical resize +10<CR>
nnoremap <S-Up> :resize -10<CR>
nnoremap <S-Down> :resize +10<CR>

"==========================================================
" Alternate escape sequences terminal emulator (terminal-emulator-input)
"==========================================================
tnoremap <Esc> <C-\><C-n>
" tnoremap <Leader>x :close< CR>


"==========================================================
" Make escape fancy ( :/ )
"==========================================================
nnoremap <C-\><C-n> <Esc>
nnoremap <silent><Esc> :call ConditionalEscape()<CR>

let g:kzsh#term_prime_delete = 0
function! ConditionalEscape()
  if bufname('%') ==? '[Command Line]'
    if mode()==? 'n'
      close
    endif
  elseif bufname('%') =~# '^term:\/\/'
    try
      close
    catch /.*/
      if g:kzsh#term_prime_delete == 1
        let g:kzsh#term_prime_delete = 0
        bd!
      else
        let g:kzsh#term_prime_delete = 1
      endif
    endtry
  else
    normal! <C-\><C-n>
  endif
endfunction

"==========================================================
" Use buffer ex view by default
"==========================================================
nnoremap : q:i
nnoremap <Leader>: :

inoremap <C-r><C-g> <Esc>:echo bufname(bufnr(''))<CR>i

"==========================================================
" Configure Deoplete syntax completion engine
"==========================================================
let g:deoplete#enable_at_startup = 1

"call deoplete#enable_logging('DEBUG', kzsh#vim_log_dir . '/deoplete.log')

"==========================================================
" Function to replace right and left quotes with un-justified quotes
"==========================================================
function! FixQuotes()
  %s/[“”]/"/g
  %s/[‘’]/'/g
endfunction

"==========================================================
" Rename tmux window when vim changes buffers
"==========================================================
augroup TmuxIntegration
  autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " .   expand("%:t"))
  autocmd VimLeave * call system("tmux setw automatic-rename")
augroup END

"==========================================================
" vim-cd to top-level of git repo
"==========================================================
function! Cdg()
  let l:root = FindGitRoot()
  cd `=l:root`
endfunction

command! Cdg :call Cdg()
cnoreabbrev <expr> cdg ((getcmdtype() is# ':' && getcmdline() is# 'cdg')?('Cdg'):('cdg'))

"==========================================================
" Remove trailing whitespaces
"==========================================================
let g:skip_whitespace = ['md']

fun! <SID>StripTrailingWhitespaces()
  if index(skip_whitespace, &ft) < 0
    let l:l = line('.')
    let l:c = col('.')
    %s/\s\+$//e
    call cursor(l:l, l:c)
  endif

endfun

"when saving, remove all trailing spaces from the file.
augroup StripWhitespaceOnSave
  autocmd FileType  autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
augroup END

"==========================================================
" Remove consecutive empty lines
"==========================================================
function! RemoveExtraEmptyLines()
  :%g/^$\n\n/d
endfunction

"==========================================================
" Copy search matches to register e.g. :CopyMatches a
"==========================================================
function! CopyMatches(reg)
  let l:hits = []
  let l:reg = ""
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let l:reg = empty(l:reg) ? '+' : l:reg
  execute 'let @' . l:reg . ' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)

"==========================================================
" Open quickfix window
"==========================================================
nnoremap <Leader>fq :copen \| silent grep!<Space>

"==========================================================
" Buffer Shortcuts
"==========================================================
nnoremap <Leader>bd :bd<CR>
nnoremap <Leader>e :execute('e ' . expand('%'))<CR>

"==========================================================
" Diff Shortcuts
"==========================================================
" Toggle Vim diff on/off
function! ToggleVimDiff()
  if &diff
    diffoff
  else
    diffthis
  endif
endfunction

noremap <Leader>gg :diffget<CR>
noremap <Leader>gp :diffput<CR>
nmap <Leader>;d :exe ToggleVimDiff()<CR>

"==========================================================
" Fugitive
"==========================================================
vnoremap <Leader>ll :'<,'>0Gclog<CR>
nnoremap <Leader>ll :silent! call ToggleFugitive()<CR>

" nnoremap <Leader>gs :Gstatus<CR>
" nnoremap <Leader>df

" command! -range FugitiveRange <line1>,<line2>call ToggleFugitive()

function! ToggleFugitive()
  if expand('%') =~# 'fugitive'
    execute('Gedit')
  else
    execute(line('.') . 'Gclog')
  end
endfunction

"==========================================================
" Tig
"==========================================================
nnoremap <Leader>tig :tabe \| execute('term tig') \| startinsert!<CR>
" nnoremap <Leader>tif :tabe \| execute('term cd ' . FindGitRootForPath(expand('%')) . ' && tig -- ' . expand('%')) \| startinsert!<CR>
"
nnoremap <Leader>tif :silent! call OpenFileHistoryInTig()<CR>

function! OpenFileHistoryInTig() 
  let filename = expand('%')
  tabe
  execute('term cd ' . FindGitRootForPath(l:filename) . ' && /usr/local/bin/tig -- ' . l:filename)
  startinsert!
endfunction

"==========================================================
" Git
"==========================================================
function! FindGitRoot()
  return FindGitRootForPath(expand('%'))
endfunction

function! FindGitRootForPath(path)
  let l:git_command = 'git rev-parse --show-toplevel 2> /dev/null'
  let l:path_change = 'cd "$(dirname "' . expand(a:path) . '")"'
  return expand(system(l:path_change . ' && ' . l:git_command)[:-2])
endfunction

function! OpenGitHubUrlForCurrentLine()
  call system("hub browse -- blob/$(git rev-parse HEAD)/" . expand('%') . "/#L" . line('.'))
endfunction

function! CopyGitHubUrlForCurrentLine()
  call system("cd " . expand('%:p:h') . "&& hub browse -c -- blob/$(git rev-parse HEAD)/" . expand('%') . "/#L" . line('.'))
endfunction

nnoremap <silent> <Leader>gx :call OpenGitHubUrlForCurrentLine()<CR>
nnoremap <silent> <Leader>ghc :call CopyGitHubUrlForCurrentLine()<CR>
nnoremap <silent> <Leader>gs :execute("tabe " . LoadMainNodeModule(expand('<cfile>'))) \| execute("lcd " . expand('%:p:h'))<CR>
 
"==========================================================
" Cucumber Acceptance Test Config
"==========================================================
function! <SID>FormatCucumberTables()
  let current_line = line('.')
  g/^\s*\|/exe ":Tabularize /|/"
  exe(':' .current_line)
endfunction

augroup TabularizeCucumberTestTables
  autocmd BufWritePre *.feature call <SID>FormatCucumberTables()
augroup END

function! RunCucumberAtLine()
  let current_line = line('.')
  tabe | term('cd $(git rev-parse --show-toplevel)/acceptance && bundle exec rake features["' . expand('%') .':' . current_line . '"]')
endfunction

"==========================================================
" Elixir Config
"==========================================================
let g:mix_format_on_save = 1

"==========================================================
" Markdown Config
"==========================================================
let g:vim_markdown_follow_anchor = 1

"==========================================================
" Goyo Config
"==========================================================

function! s:goyo_leave()
  set background=dark
  colorscheme gruvbox
  nmap <S-L> gt
  nmap <S-H> g<S-t>
endfunction

function! s:goyo_enter()
  nmap <S-L> :bn<CR>
  nmap <S-H> :bp<CR>

endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

nnoremap <Leader>go :Goyo<CR>

"==========================================================
" Buffer functions
"==========================================================
function! GitRootsForAllBuffers()
  return Filtered(function('len'), Mapped(function('FindGitRootForPath'), AllBufferFileNames()))
endfunction

function! AllBufferFileNames()
  return map(filter(range(0,bufnr('$')), 'buflisted(v:val)'), "fnamemodify(bufname(v:val), ':p')")
endfunction

"==========================================================
" Utility functions
"==========================================================
function! Mapped(fn, l)
  return OperateOnEnumerable(a:fn, a:l, 'map')
endfunction

function! Filtered(fn, l)
  return OperateOnEnumerable(a:fn, a:l, 'filter')
endfunction

function! OperateOnEnumerable(fn, list, operation)
  let l:new_list = deepcopy(a:list)
  execute('call ' . a:operation . "(l:new_list,  string(a:fn) . '(v:val)')")

  return l:new_list
endfunction

function! VisualSelection()
  if mode() ==? 'v'
    let [l:line_start, l:column_start] = getpos('v')[1:2]
    let [l:line_end, l:column_end] = getpos('.')[1:2]
  else
    let [l:line_start, l:column_start] = getpos("'<")[1:2]
    let [l:line_end, l:column_end] = getpos("'>")[1:2]
  end
  if (line2byte(l:line_start) + l:column_start) > (line2byte(l:line_end) + l:column_end)
    let [l:line_start, l:column_start, l:line_end, l:column_end] =
          \   [l:line_end, l:column_end, l:line_start, l:column_start]
  end
  let l:lines = getline(l:line_start, l:line_end)
  if len(l:lines) == 0
    return ''
  endif
  let l:lines[-1] = l:lines[-1][: l:column_end - 1]
  let l:lines[0] = l:lines[0][l:column_start - 1:]
  return join(l:lines, "\n")
endfunction

"==========================================================
" colorizer setup
"==========================================================
" lua require 'colorizer'.setup { 'css'; 'javascript'; 'html' }

"==========================================================
" vim-jsx config
"==========================================================
let g:jsx_ext_required = 0

"==========================================================
" Spelling ignores
"==========================================================
syn match UrlNoSpell '^((?:https?:\/\/)?[^./]+(?:\.[^./]+)+(?:\/.*)?)$' contains=@NoSpell

"==========================================================
" Colorscheme and overrides
"==========================================================
set background=dark
" let g:solarized_contrast="none"
" colorscheme solarized
colorscheme gruvbox
