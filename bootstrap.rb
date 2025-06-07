#!/usr/bin/env ruby

require '~/.dotfiles/helpers'
require 'optparse'
require 'net/http'
require 'uri'
require 'json'
require 'fileutils'
require 'open-uri'
require 'English'

def bootstrap_nvim(server:, package_manager:)
  install_package(package_manager, 'neovim')
  install_package(package_manager, 'python3-neovim') # linux
  install_package(package_manager, 'bat')
  install_package(package_manager, 'fzf')
  install_package(package_manager, 'ripgrep')
  install_package(package_manager, 'fd')
  install_package(package_manager, 'fd-find')

  if server
    puts 'SKIPPING: running :PaqInstall'.noop
  else
    puts 'running :PaqInstall'.doing
    `nvim --headless "+PaqInstall" +q`
    puts '\n'
  end

  puts 'installing language servers from package.json'.doing
  `npm install --prefix ~/.dotfiles/neovim/.config/nvim/language_servers/`

  puts 'installing the lua language server binary'.doing
  url = URI('https://api.github.com/repos/LuaLS/lua-language-server/releases/latest')
  response = Net::HTTP.get(url)
  data = JSON.parse(response)
  selected_asset = data['assets'].find do |asset|
    lua_ls_regex = if linux?
                     /lua-language-server-.*-linux-x64.tar.gz/
                   else
                     /lua-language-server-.*-darwin-arm64.tar.gz/
                   end

    lua_ls_regex.match?(asset['name'])
  end

  lua_ls_dir = File.expand_path('~/.dotfiles/neovim/.config/nvim/language_servers/lua-language-server-release')
  FileUtils.rm_rf [lua_ls_dir]
  FileUtils.mkdir_p [lua_ls_dir]

  download = URI.open(selected_asset['browser_download_url'])
  lua_ls_tar = File.expand_path("~/.dotfiles/neovim/.config/nvim/language_servers/#{selected_asset['name']}")
  IO.copy_stream(download, lua_ls_tar)
  `tar --extract --gzip --file #{lua_ls_tar} --directory #{lua_ls_dir}`
end

if __FILE__ == $PROGRAM_NAME
  options = {}

  OptionParser.new do |opts|
    opts.banner = 'Usage: ./bootstrap.rb [options]'

    opts.on('-s', '--server') do
      options['server'] = true
    end

    opts.on('-pPACKAGE_MANAGER', '--package-manager=PACKAGE_MANAGER', '{brew,pacman,dnf,apt}') do |opt|
      options['package_manager'] = opt
      raise OptionParser::InvalidArgument unless validate_package_manager opt
    end
  end.parse!

  raise OptionParser::MissingArgument if options['package_manager'].nil?

  server = options['server'] or false
  bootstrap_nvim(server: server, package_manager: options['package_manager'])
end
