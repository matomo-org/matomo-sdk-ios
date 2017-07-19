include FileUtils::Verbose

namespace :test do
  desc 'Prepare tests'
  task :prepare do
  end

  desc 'Run the PiwikTracker Unit tests'
  task ios: :prepare do
    run_tests('PiwikTracker', 'iphonesimulator')
    run_tests('PiwikTracker', 'iphonesimulator', 'platform=iOS Simulator,name=iPhone 6,OS=10.2')
    run_tests('PiwikTracker', 'iphonesimulator', 'platform=iOS Simulator,name=iPhone 6,OS=9.3')
    run_tests('PiwikTracker', 'iphonesimulator', 'platform=iOS Simulator,name=iPhone 6,OS=8.4')
  end

  desc 'Build the PiwikTracker iOS demo'
  task ios_demo: :prepare do
    run_build('ios', 'iphonesimulator')
    build_failed('iOS') unless $?.success?
  end

  desc 'Build the PiwikTracker OSX demo'
  task osx_demo: :prepare do
    run_build('macos', 'macosx', 'platform=macOS,arch=x86_64')
    build_failed('macOS') unless $?.success?
  end

  desc 'Build the PiwikTracker tvOS demo'
  task tvos_demo: :prepare do
    run_build('tvos', 'appletvsimulator', 'platform=tvOS Simulator,name=Apple TV 1080p,OS=10.2')
    build_failed('tvOS') unless $?.success?
  end
end

desc 'Run the PiwikTracker tests for iOS & Mac OS X'
task :test do
  Rake::Task['test:ios'].invoke
  Rake::Task['test:ios_demo'].invoke
  Rake::Task['test:osx_demo'].invoke
  Rake::Task['test:tvos_demo'].invoke
end

task default: 'test'

private

def run_build(scheme, sdk, destination = 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1')
  sh("xcodebuild -workspace PiwikTracker.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -destination '#{destination}' -configuration Release clean build | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def run_tests(scheme, sdk, destination = 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1')
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
