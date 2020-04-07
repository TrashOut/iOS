
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
    pod 'FBSDKCoreKit'
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FacebookShare'
    
    pod 'Cache', '5.2.0'
    pod 'SwiftDate', '6.1.0'
    
    pod 'Charts', '3.2.2'
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
