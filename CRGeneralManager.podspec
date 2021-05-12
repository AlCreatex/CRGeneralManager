Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '11.4'
s.name = "CRGeneralManager"
s.summary = "CRGeneralManager"
s.requires_arc = true

# 2
s.version = "1.0.24"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Alex Lebed" => "al@createx.by" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/AlCreatex/CRGeneralManager"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/AlCreatex/CRGeneralManager.git",
             :tag => "#{s.version}" }

# 7
s.static_framework = true
s.dependency 'CRSupportManager', :git => "https://github.com/AlCreatex/CRSupportManager.git"
s.dependency 'lottie-ios'
s.dependency 'SwiftyStoreKit'
s.dependency 'Firebase'
s.dependency 'Firebase/Analytics'
s.dependency 'Firebase/Crashlytics'
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

# 10
s.swift_version = "5"

end
