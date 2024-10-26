#!/usr/bin/env ruby

require_relative File.expand_path('~/.dotfiles/helpers.rb')

package_manager = get_package_manager_arg
validate_package_manager package_manager

install_package package_manager, 'neovim'
install_package package_manager, 'python3-neovim' if package_manager == 'dnf'

install_package package_manager, 'fzf'
install_package package_manager, 'ripgrep'
install_package package_manager, 'watchman'

if package_manager == 'dnf'
  install_package package_manager, 'fd-find'
else
  install_package package_manager, 'fd'
end

# increase num allowed open fd
`ulimit -n 1024`
puts 'running :PlugInstall'.doing
`nvim --headless "+PlugInstall" +qa`
