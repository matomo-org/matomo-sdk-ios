include FileUtils::Verbose

namespace :test do
  desc 'Prepare tests'
  task :prepare do
  end

  desc 'Run the PiwikTracker Unit tests'
  task ios: :prepare do
    run_tests('PiwikTracker', 'iphonesimulator')
  end

  # currently this links against nonexisting files
  # once we implemented certain features we can adapt them in
  # the iOS demo app
  desc 'Build the PiwikTracker iOS demo'
  task ios_demo: :prepare do
    # run_build('PiwikTrackeriOSDemo', 'iphonesimulator')
    # build_failed('iOS') unless $?.success?
  end

  # right now there is no OSX demo app
  desc 'Build the PiwikTracker OSX demo'
  task osx_demo: :prepare do
    # run_build('PiwikTrackerOSXDemo', 'macosx')
    # build_failed('OSX') unless $?.success?
  end
end

desc 'Run the PiwikTracker tests for iOS & Mac OS X'
task :test do
  Rake::Task['test:ios'].invoke
  Rake::Task['test:ios_demo'].invoke
  Rake::Task['test:osx_demo'].invoke if is_mavericks_or_above
end

task default: 'test'

private

def run_build(scheme, sdk, destination = 'platform=iOS Simulator,name=iPhone 6,OS=10.0')
  sh("xcodebuild -workspace PiwikTracker.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -destination '#{destination}' -configuration Release clean build | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def run_tests(scheme, sdk, destination = 'platform=iOS Simulator,name=iPhone 6,OS=10.0')
  sh("xcodebuild -workspace PiwikTracker.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -destination '#{destination}' -configuration Debug clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def is_mavericks_or_above
  osx_version = `sw_vers -productVersion`.chomp
  Gem::Version.new(osx_version) >= Gem::Version.new('10.9')
end

def build_failed(platform)
  puts red("#{platform} build failed")
  exit $?.exitstatus
end

def tests_failed(platform)
  puts red("#{platform} unit tests failed")
  exit $?.exitstatus
end

def red(string)
  "\033[0;31m! #{string}"
end
