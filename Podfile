platform :ios, '10.0'

# ignore all warnings from all pods
inhibit_all_warnings!


def shared_pods
    use_frameworks!
    
    # Network
    pod 'Alamofire'
    pod 'Moya/RxSwift'
 
    # RX Core
    pod 'RxSwift'
    pod 'RxCocoa'
    
    # RX Extension
    pod 'RxAlamofire'
    pod 'RxDataSources'    
    
    # UI
    pod 'SnapKit'
    pod 'ReusableKit'

end

# 각 target 별 dependency 선언
target 'MobilityTest' do
    shared_pods
end
