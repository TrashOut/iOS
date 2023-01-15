
platform :ios, '12.0'
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
    pod 'Firebase/Crashlytics'
    pod 'Firebase/Analytics'
    
    pod 'Cache', '5.2.0'
    pod 'SwiftDate', '6.1.0'
    
    pod 'Charts', '4.1.0'
end

target 'TrashOut-Prod' do
    common_pods_for_target
end

target 'TrashOutTests' do
    common_pods_for_target
end

target 'TrashOutUITests' do
    common_pods_for_target
end
