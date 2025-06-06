class String
  @no_color = "\033[0m"

  def error
    "\e[31m#{self}\e[0m#{@no_color}"
  end

  def query
    "\e[32m#{self}\e[0m#{@no_color}"
  end

  def noop
    "\e[34m#{self}\e[0m#{@no_color}"
  end

  def doing
    "\e[35m#{self}\e[0m#{@no_color}"
  end
end

def validate_package_manager(package_manager)
  valid_package_managers = %w[brew pacman dnf apt]
  valid_package_managers.include? package_manager
end

def is_linux
  `uname -s`.strip
end

def install_package(package_manager, package)
  puts "installing #{package}".doing

  case package_manager
  when 'brew'
    `brew install #{package}`
  when 'dnf'
    `sudo dnf install --assumeyes #{package}`
  when 'pacman'
    `sudo pacman --sync --needed --quiet --noconfirm #{package}`
  when 'apt'
    puts 'not implemented yet'
  else
    raise ArgumentError 'package_manager must be one of {brew,pacman,dnf,apt}'
  end
end
