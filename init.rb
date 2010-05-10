require "heroku/command/manifest"

Heroku::Command::Help.group('Gem Manifest') do |group|
  group.command('manifest:generate', 'Generate a gem manifest from a Rails app')
  group.command('manifest:write',    'Write a generated gem manifest to .gems')
end
