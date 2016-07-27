#!/bin/bash
#       __     ___      __     ___            __  __ /\_\    ___ ___
#     /'_ `\  / __`\  /'_ `\  / __`\  _______/\ \/\ \\/\ \ /' __` __`\
#    /\ \L\ \/\ \L\ \/\ \L\ \/\ \L\ \/\______\ \ \_/ |\ \ \/\ \/\ \/\ \
#    \ \____ \ \____/\ \____ \ \____/\/______/\ \___/  \ \_\ \_\ \_\ \_\
#     \/___L\ \/___/  \/___L\ \/___/           \/__/    \/_/\/_/\/_/\/_/
#       /\____/         /\____/
#       \_/__/          \_/__/
#
#   This is the personal vim setup of Joshua Barone
#   This setup is for Mac Os X. And is designed to setup MacVim with
#   spf13-vim configurations.
#
#   Copyright 2016 Joshua Barone
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

############################## Helper Functions

msg() {
    printf '%b\n' "$1" >&2
}

success() {
    msg "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

program_exists() {
    return $( which -s "$1" )
}

brew_formula_exists() {
    if ! program_exists brew; then
        error "Homebrew is not installed"
    fi

    if brew list -1 | grep -q "^$1\$"; then
        return 0
    else
        return 1
    fi
}

function_exists() {
    return $( declare -f "$1" >/dev/null )
}

############################## MAIN()

if [ -z "$HOME" ]; then
    error "You must have your \$HOME environment variable set"
fi

if ! program_exists "brew"; then
    msg "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [ "$?" -ne 0 ]; then
        error "Error installing Homebrew"
    else
        success "Brew successfully installed"
    fi
fi

if [ ! -d `brew --prefix`/Library/Taps/caskroom/homebrew-fonts ]; then
    msg "Installing Hack font"
    brew tap caskroom/fonts
    if [ "$?" -ne 0 ]; then
        error "Error tapping caskroom/fonts"
    fi
    brew cask install font-hack
    if [ "$?" -ne 0 ]; then
        error "Error installing Hack font"
    fi
    success "Hack font installed"
fi

if ! program_exists "mvim"; then
    msg "Installing MacVim"
    brew install macvim --with-cscope --with-lua --with-override-system-vim
    if [ "$?" -ne 0 ]; then
        error "Error installing MacVim"
    fi
    brew linkapps macvim
    if [ "$?" -ne 0 ]; then
        error "Error linking MacVim"
    fi
    success "Macvim successfully installed"
fi

if ! brew_formula_exists "bash-completion"; then
    msg "Installing bash-completion"
    brew install bash-completion
    if [ "$?" -ne 0 ]; then
        error "Error installing bash-completion"
    fi
    success "bash-completion successfully installed"
fi

if ! brew_formula_exists "git"; then
    msg "Installing git"
    brew install git
    if [ "$?" -ne 0 ]; then
        error "Error installing git"
    fi
    success "git successfully installed"
fi

if ! brew_formula_exists "python"; then
    msg "Installing python"
    brew install python
    if [ "$?" -ne 0 ]; then
        error "Error installing python"
    fi
    success "python successfully installed"
fi

if ! function_exists "virtualenvwrapper"; then
    msg "Installing virtualenvwrapper"
    pip install virtualenvwrapper
    if [ "$?" -ne 0 ]; then
        error "Error installing virtualenvwrapper"
    fi
    success "virtualenvwrapper successfully installed"
fi

if ! brew_formula_exists "ctags"; then
    msg "Installing ctags"
    brew install ctags
    if [ "$?" -ne 0 ]; then
        error "Error installing ctags"
    fi
    success "ctags successfully installed"
fi

if ! program_exists "go"; then
    msg "Installing Go"
    brew install go
    if [ "$?" -ne 0 ]; then
        error "Error installing Go"
    fi
    success "Go successfully installed"
fi

msg "Downloading .bash_profile for Mac"
curl -L -o "$HOME/.bash_profile" https://gist.githubusercontent.com/jbarone/d84cca4624349746cd1c0ef48d0102da/raw/mac_bash_profile
source "$HOME/.bash_profile"
success ".bash_profile setup"

if ! program_exists "impl"; then
    msg "Installing Impl"
    go get -u github.com/josharian/impl
    if [ "$?" -ne 0 ]; then
        error "Error installing Impl"
    fi
    success "Impl successfully installed"
fi

if [ ! -f "$HOME/.vimrc.before.local" ]; then
    msg "Setting up .vimrc.before.local"
    echo "let g:spf13_bundle_groups=['general', 'writing', 'programming', 'neocomplete', 'php', 'python', 'javascript', 'html', 'ruby', 'go', 'misc', ]" >"$HOME/.vimrc.before.local"
    echo "let g:airline_powerline_fonts=1" >>"$HOME/.vimrc.before.local"
    success "Created .vimrc.before.local"
fi

if [ ! -f "$HOME/.vimrc.bundles.local" ]; then
    msg "Setting up .vimrc.bundles.local"
    cat >"$HOME/.vimrc.bundles.local" <<EOF
if count(g:spf13_bundle_groups, 'programming')
    Bundle 'airblade/vim-gitgutter'
    Bundle 'Xuyuanp/nerdtree-git-plugin'
    Bundle 'gregsexton/gitv'
endif
if count(g:spf13_bundle_groups, 'programming')
    if executable('impl')
        Bundle 'rhysd/vim-go-impl'
    endif
endif
EOF
    success "Created .vimrc.bundles.local"
fi

if [ ! -f "$HOME/.vimrc.local" ]; then
    msg "Setting up .vimrc.local"
    cat >"$HOME/.vimrc.local" <<EOF
set timeout
set timeoutlen=100
set encoding=utf8
set colorcolumn=80,120          " Add vertical lines to columns
set infercase                   " Case inference search
set magic                       " For regular expressions turn magic on
set lazyredraw                  " Don't redraw while executing macros
set showmatch                   " Show matching pair
set mat=2

set noerrorbells
set novisualbell
set t_vb=
set tm=500

set nrformats=octal,hex

let g:syntastic_go_checkers = ['gometalinter']

let g:syntastic_mode_map = {'mode': 'active', 'active_filetypes': ['go']}

let g:snips_author = 'Joshua Barone <joshua.barone@gmail.com>'

let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

noremap <leader><Space> :call StripTrailingWhitespace()<CR>
augroup whitespace
    autocmd BufWritePre *.rb call StripTrailingWhitespace()
    autocmd BufWritePre *.py call StripTrailingWhitespace()
    autocmd BufWritePre *.go call StripTrailingWhitespace()
    autocmd BufWritePre *.c call StripTrailingWhitespace()
    autocmd BufWritePre *.cpp call StripTrailingWhitespace()
    autocmd BufWritePre *.coffee :call StripTrailingWhitespace()
augroup END

if LINUX() && has("gui_running")
    set guifont=Hack\ Regular\ 12,Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
elseif OSX() && has("gui_running")
    set guifont=Hack\ Regular:h12,Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
elseif WINDOWS() && has("gui_running")
    set guifont=Hack:h10,Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
endif
EOF
    success "Created .vimrc.local"
fi

if [ -d "$HOME/.spf13-vim-3" ]; then
    msg "Updating spf13-vim"
    cd $HOME/.spf13-vim-3
    git pull
    vim "+set nomore" +BundleInstall! +BundleClean +qall
    success "Updated spf13-vim"
else
    msg "Installing spf13-vim"
    curl http://j.mp/spf13-vim3 -L -o - | sh
    success "Installed spf13-vim"
fi

msg "Installing vim-go binaries"
vim "+set nomore" "+GoInstallBinaries" "+qall"
success "Installed vim-go binaries"
