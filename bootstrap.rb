# !/usr/bin/env ruby

require_relative 'helpers'
require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: ./scratch.rb [options]'

  opts.on('-s', '--server') do
    options[:server] = true
  end

  opts.on('-pPACKAGE_MANAGER', '--package-manager=PACKAGE_MANAGER', '{brew,pacman,dnf,apt}') do |opt|
    options[:package_manager] = opt
    raise OptionParser::InvalidArgument unless validate_package_manager opt
  end
end.parse!

raise OptionParser::MissingArgument if options[:package_manager].nil?

install_package(options[:package_manager], 'neovim')
install_package(options[:package_manager], 'python3-neovim') # linux
install_package(options[:package_manager], 'bat')
install_package(options[:package_manager], 'fzf')
install_package(options[:package_manager], 'ripgrep')
install_package(options[:package_manager], 'fd')
install_package(options[:package_manager], 'fd-find')

if options[:server]
  puts 'SKIPPING: running :PaqInstall'.noop
else
  puts 'running :PaqInstall'.doing
  `nvim --headless "+PaqInstall" +q`
end
