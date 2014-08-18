xcodeproj 'PiwikTracker'
workspace 'PiwikTracker'

inhibit_all_warnings!

def import_pods
  podspec :name => 'PiwikTracker'
end

target :ios do
  platform :ios, '7.0'
  link_with ['PiwikTracker', 'PiwikTrackeriOSDemo']
  import_pods
end

target :osx do
  platform :osx, '10.8'
  link_with ['PiwikTrackerOSXDemo']
  import_pods
end