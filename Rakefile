require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new(:yard)

task default: :spec

desc "Prepare release: bump version, update changelog, commit, tag"
task :prepare, [:version] do |_t, args|
  new_version = args[:version]
  raise "Usage: rake prepare[1.2.0]" unless new_version

  version_file = File.expand_path("lib/asciidoctor_diagram_layout/version.rb", __dir__)
  changelog_file = File.expand_path("CHANGELOG.md", __dir__)

  unless system("git", "diff", "--quiet") && system("git", "diff", "--cached", "--quiet")
    raise "Working tree is not clean. Commit or stash changes first."
  end

  changelog = File.read(changelog_file)
  unless changelog.match?(/^## \[Unreleased\]$/)
    raise "CHANGELOG.md must contain exactly '## [Unreleased]' (no date, no other text) as the first version entry."
  end

  version_rb = File.read(version_file)
  current = version_rb[/\bVERSION\s*=\s*"([^"]+)"/, 1]
  raise "Cannot find VERSION string in #{version_file}" unless current

  today = Time.now.strftime("%Y-%m-%d")
  updated = version_rb.sub(/\bVERSION\s*=\s*"[^"]+"/, %(VERSION = "#{new_version}"))
  File.write(version_file, updated)

  updated_changelog = changelog.sub(/^## \[Unreleased\]$/, "## [#{new_version}] - #{today}")
  File.write(changelog_file, updated_changelog)

  sh("git", "add", version_file, changelog_file)
  sh("git", "commit", "-m", "Release #{new_version}")
  sh("git", "tag", "v#{new_version}")

  puts "Done. Run: git push --follow-tags"
end
