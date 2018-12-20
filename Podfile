
platform :ios, '9.0'
use_frameworks!

def common_pods_for_target
    # Networking
    pod 'Alamofire'
    pod 'AlamofireImage'
    
    # Firebase SDK
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Messaging'
    pod 'Firebase/Storage'
    
    # Crashlytics
    pod 'Fabric'
    pod 'Crashlytics'
    
    # Facebook SDK
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FacebookShare'
    
    pod 'Cache', '2.2.2'
    pod 'SwiftDate', '~> 4.0.11'
    
    pod 'Charts'
    pod 'Keychain'
end

target 'TrashOut-Prod' do
    common_pods_for_target
end

target 'TrashOut-Stage' do
    common_pods_for_target
end

target 'TrashOutTests' do
    common_pods_for_target
end

target 'TrashOutUITests' do
    common_pods_for_target
end

# workaround for pods swift version, remove me with new cocoa pod release
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['SwiftDate', 'Cache'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end
