source 'https://github.com/CocoaPods/Specs.git'

abstract_target :example do
  platform :ios, '7.0'
  inhibit_all_warnings!
  workspace 'PiwikTracker'
  project 'Example/Example'
  target :ios do
    pod 'PiwikTracker', path: './'
  end
  #target :osx do
    # platform :osx, '10.8'
    # link_with ['PiwikTrackerOSXDemo']
    # pod 'PiwikTracker', :path => './'
  #end
end
