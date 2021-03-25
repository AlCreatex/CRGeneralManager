Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "CRGeneralManager"
s.summary = "CRGeneralManager"
s.requires_arc = true

# 2
s.version = "0.0.3"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Keegan Rush" => "al@createx.by" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/AlCreatex/CRGeneralManager"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/AlCreatex/CRGeneralManager.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'lottie-ios'
s.dependency 'NVActivityIndicatorView'
s.dependency 'DeviceKit'
s.dependency 'SwiftyStoreKit'
s.dependency 'Firebase/Auth'
s.dependency 'Firebase/Analytics'
s.dependency 'Firebase/Crashlytics'
s.dependency 'Firebase/RemoteConfig'
s.dependency 'FBSDKCoreKit'
s.dependency 'FBAudienceNetwork'
s.dependency 'YandexMobileMetrica'
s.dependency 'AppsFlyerFramework'
s.dependency 'Google-Mobile-Ads-SDK'
s.dependency 'GoogleMobileAdsMediationIronSource'
s.dependency 'GoogleMobileAdsMediationAdColony'
s.dependency 'GoogleMobileAdsMediationAppLovin'
s.dependency 'GoogleMobileAdsMediationFacebook'
s.dependency 'GoogleMobileAdsMediationUnity'
s.dependency 'GoogleMobileAdsMediationTapjoy'
s.dependency 'GoogleMobileAdsMediationVungle'

# 8
s.source_files = "CRGeneralManager/**/*.{swift}"

# 9
s.resources = "CRGeneralManager/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5"

end
