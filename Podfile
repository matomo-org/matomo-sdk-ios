source 'https://cdn.cocoapods.org/'

abstract_target :example do
  use_frameworks!
  inhibit_all_warnings!
  project 'MatomoTracker'
  workspace 'MatomoTracker'

  target :iOSExampleApp do
    platform :ios, '11.0'
    project 'Example/ios/ios'
    pod 'MatomoTracker', path: './'
  end

  target :macOSExampleApp do
    platform :osx, '10.13'
    project 'Example/macos/macos'
    pod 'MatomoTracker', path: './'
  end

  target :tvOSExampleApp do
    platform :tvos, '10.2'
    project 'Example/tvos/tvos'
    pod 'MatomoTracker', path: './'
  end

end

target 'MatomoTrackerTests' do
  use_frameworks!
  platform :ios, '13.0'
  inhibit_all_warnings!
  project 'MatomoTracker'
  workspace 'MatomoTracker'
  inherit! :search_paths
  
  pod 'Quick', '~> 7.0'
  pod 'Nimble', '~> 12.0'
end
