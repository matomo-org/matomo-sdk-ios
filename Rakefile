include FileUtils::Verbose

namespace :test do
  
  desc "Prepare tests"
  task :prepare do  
  end

  desc "Run the PiwikTracker tests for iOS"
  task :ios => :prepare do
    run_tests('PiwikTracker', 'iphonesimulator')
    tests_failed('iOS') unless $?.success?
  end

  desc "Run the PiwikTracker tests for Mac OS X"
  task :osx => :prepare do
    run_tests('PiwikTrackerOSXDemo', 'macosx')
    tests_failed('OSX') unless $?.success?
  end
end

desc "Run the PiwikTracker tests for iOS & Mac OS X"
task :test do
  Rake::Task['test:ios'].invoke
  Rake::Task['test:osx'].invoke if is_mavericks_or_above
end

task :default => 'test'


private

def run_tests(scheme, sdk)
  sh("xcodebuild -workspace PiwikTracker.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' -configuration Release clean build | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def is_mavericks_or_above
  osx_version = `sw_vers -productVersion`.chomp
  Gem::Version.new(osx_version) >= Gem::Version.new('10.9')
end

def tests_failed(platform)
  puts red("#{platform} unit tests failed")
  exit $?.exitstatus
end

def red(string)
 "\033[0;31m! #{string}"
end
