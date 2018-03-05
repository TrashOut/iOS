
platform :ios, '9.0'

target 'TrashOut' do
  use_frameworks!

# Networking
  pod 'Alamofire', '~> 4.0.0'
  pod 'AlamofireImage'

# Firebase SDK
  pod 'Firebase', '~> 3.6.0'
  # pod 'Firebase/AdMob'
  pod 'Firebase/Analytics'#, '~> 3.4.2'
  pod 'Firebase/AppIndexing'#, '~> 1.1.0'
  pod 'Firebase/Auth'#, '~> 3.0.5'
  pod 'Firebase/Crash'#, '~> 1.0.7'
  # pod 'Firebase/Database', ''
  # pod 'Firebase/DynamicLinks'
  # pod 'Firebase/Invites'
  # pod 'Firebase/Messaging'
  # pod 'Firebase/RemoteConfig'
  pod 'Firebase/Storage'

# Facebook SDK
  pod 'FBSDKLoginKit', '~> 4.18'  
  pod 'FBSDKShareKit', '~> 4.18'

  pod 'Cache', '~> 2.2.1'
  # pod 'SSZipArchive', '~> 1.6.1'
  pod 'SwiftDate', '~> 4.0.11'

  pod 'Charts', '~> 3.0.1'

  target 'TrashOutTests' do
    inherit! :search_paths
	pod 'Firebase', '~> 3.6.0' # i wonder why its not working as inherit	
  end

  target 'TrashOutUITests' do
    inherit! :search_paths
  end

end

# workaround for pods swift version, remove me with new cocoa pod release
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.2'
		end
	end
end
