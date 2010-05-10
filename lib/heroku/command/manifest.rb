class Heroku::Command::Manifest < Heroku::Command::Base

  def generate
    load_environment
    display generate_manifest
  end

  def write
    load_environment
    manifest = generate_manifest
    File.open(".gems", "w") { |file| file.puts manifest }
    display "Manifest written"
  end

private ######################################################################

  def rails_boot_file
    @rails_boot_file ||= File.join(Dir.pwd, 'config', 'boot.rb')
  end

  def rails_environment_file
    @rails_environment_file ||= File.join(Dir.pwd, 'config', 'environment.rb')
  end

  def check_for_rails
    File.exists?(rails_boot_file)
  end

  def load_environment
    error "You do not appear to be in a Rails app" unless check_for_rails

    redirect_stdio do
      display "Loading Rails environment"
      require rails_boot_file
      require rails_environment_file
    end
  end

  def generate_manifest
    ENV["RAILS_ENV"] ||= "production"

    manifest = Rails.configuration.gems.map do |gem|
      entry = gem.name

      if gem.requirement && !(gem.requirement == Gem::Requirement.default)
        entry << " --version '#{gem.requirement}'"
      end

      if gem.source
        entry << " --source '#{gem.source}'"
      end

      entry
    end.join("\n")
  end

  def redirect_stdio
    old_stdout = $stdout.dup
    old_stderr = $stderr.dup
    $stdout.reopen("/dev/null", "w")
    $stderr.reopen("/dev/null", "w")
    yield
    $stdout = old_stdout.dup
    $stderr = old_stderr.dup
  end

end
