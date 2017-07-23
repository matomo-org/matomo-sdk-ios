
source 'https://github.com/CocoaPods/Specs.git'


abstract_target :example do
  inhibit_all_warnings!
  workspace 'PiwikTracker'

  target :PiwikTrackeriOSDemo do
    platform :ios, '7.0'
    pod 'PiwikTracker', path: './'
  end

  target :PiwikTrackerOSXDemo do
    platform :osx, '10.12'
    pod 'PiwikTracker', path: './'
  end

end


#target :iosafnetworking1 do
#  platform :ios, '7.0'
#  link_with ['PiwikTracker+AFNetworking1']
#  pod 'PiwikTracker/AFNetworking1', :path => './'
#end


# target :iosafnetworking2 do
#   platform :ios, '7.0'
#   link_with ['PiwikTracker+AFNetworking2']
#   pod 'PiwikTracker/AFNetworking2', :path => './'
# end