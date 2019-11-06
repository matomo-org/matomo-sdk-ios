include FileUtils::Verbose

namespace :test do
  desc 'Prepare tests'
  task :prepare do
  end

  desc 'Run the MatomoTracker Unit tests'
  task ios: :prepare do
    run_tests('MatomoTracker', 'iphonesimulator', 'platform=iOS Simulator,name=iPhone 6,OS=11.2')
    build_failed('tests') unless $?.success?
    run_tests('MatomoTracker', 'iphonesimulator', 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1')
    build_failed('tests') unless $?.success?
  end

  desc 'Build the MatomoTracker iOS demo'
  task ios_demo: :prepare do
    run_build('ios', 'iphonesimulator')
    build_failed('iOS') unless $?.success?
  end

  desc 'Build the MatomoTracker OSX demo'
  task osx_demo: :prepare do
    run_build('macos', 'macosx', 'platform=macOS,arch=x86_64')
    build_failed('macOS') unless $?.success?
  end

  desc 'Build the MatomoTracker tvOS demo'
  task tvos_demo: :prepare do
    run_build('tvos', 'appletvsimulator', 'platform=tvOS Simulator,name=Apple TV,OS=11.2')
    build_failed('tvOS') unless $?.success?
  end
end

namespace :package_manager do
  desc 'Prepare tests'
  task :prepare do
  end

  desc 'Builds the project with Carthage'
  task carthage: :prepare do
    sh("carthage build --no-skip-current") rescue nil
    package_manager_failed('Carthage integration') unless $?.success?
  end

  desc 'Builds the project with the Swift Package Manager'
  task spm: :prepare do
    sh("swift build") rescue nil
    package_manager_failed('Swift Package Manager') unless $?.success?
  end
end


desc 'Run the MatomoTracker tests for iOS & Mac OS X'
task :test do
  Rake::Task['test:ios'].invoke
  Rake::Task['test:ios_demo'].invoke
  Rake::Task['test:osx_demo'].invoke
  Rake::Task['test:tvos_demo'].invoke
end

desc 'Check the integration of MatomoTracker with package managers'
task :build_with_package_manager do
  Rake::Task['package_manager:carthage'].invoke
  Rake::Task['package_manager:spm'].invoke
end

task default: 'test'


private

def run_build(scheme, sdk, destination = 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1')
  sh("xcodebuild -workspace MatomoTracker.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -destination '#{destination}' -configuration Release clean build | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def run_tests(scheme, sdk, destination = 'platform=iOS Simulator,name=iPhone 6,OS=10.3.1')
  sh("xcodebuild -workspace MatomoTracker.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -destination '#{destination}' -configuration Debug clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
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

def package_manager_failed(package_manager)
  puts red("Integration with #{package_manager} failed")
  exit $?.exitstatus
end

def red(string)
  "\033[0;31m! #{string}"
end
