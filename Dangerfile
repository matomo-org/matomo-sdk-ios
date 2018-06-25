# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"
has_pod_changes = !git.modified_files.grep(/MatomoTracker/).empty?

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

has_changelog_updates = git.modified_files.include?("CHANGELOG.md")
if has_pod_changes && !has_changelog_updates && !declared_trivial
  fail("Please add a line to the `CHANGELOG.md` since you changed the SDK.")
end

has_readme_updates = git.modified_files.include?("README.md")
if has_pod_changes && !has_readme_updates && !declared_trivial
  warn("Are there any changes that should be explained in the `README.md`?")
end