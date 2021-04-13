# Usage

## CocoaPods Install
Add ```pod 'CRGeneralManager', :git => "https://github.com/AlCreatex/CRGeneralManager.git"``` to your Podfile. "CRGeneralManager" is the name of the library.

## GoogleAdsManager
1) При первом запуске приложения, вы можете вызвать configuration, **НО ЕСЛИ ВЫ ЗАПУСКАЕТЕ AppManager, ВЫ МОЖЕТЕ ПРОПУСТИТЬ ЭТОТ ПУНКТ**:

```swift
GoogleAdsManager.shared.configuration()
```

2) Далее внутри приложения для показа interstitial рекламы, вы должны вызвать:

```swift
GoogleAdsManager.shared.presentInterstitial(viewController: self) {
   "Ваши действия после того как реклама закроется или же произойдет ошибка загрузки рекламы"
}
```

## StoreManager
1) При первом запуске приложения, вы можете вызвать configuration, **НО ЕСЛИ ВЫ ЗАПУСКАЕТЕ AppManager, ВЫ МОЖЕТЕ ПРОПУСТИТЬ ЭТОТ ПУНКТ**:

```swift
StoreManager.shared.configuration()
```

2) Далее внутри приложения для офрмления покупки или же ее восстановления, вы должны вызвать:

Оформление подписки:
```swift
StoreManager.shared.purchase(product: "Пишем ключ из ProductList") { (result) in
   switch result {
      case .successful:
         print("successful")
      case .failed:
         print("failed")
      case .cancelled:
         print("cancelled")
   }
}
```

Восстановление покупки:
```swift
StoreManager.shared.restore { (result) in
   switch result {
      case .successful:
         print("successful")
      case .failed:
         print("failed")
   }
}
```

## AnalyticsManager
1) Для отправки ивента, вы должны вызвать:

```swift
AnalyticsManager.trackWith(eventName: .init(rawValue: "Выбрать из списка нужный вам ивент или же написать свой"))
```

2) Отправлять ивент по успешной подписке как и отмене покупки не требуется, это уже прописано внутри StoreManager.

## AppManager
1) Для запуска всех сервисов, вы должны вызывать в AppDelegate:

```swift
AppManager().configuration(application: application, 
			   launchOptions: launchOptions, 
			   userAcquisitionServer: .init(rawValue: "Выбрать из списка нужный вам сервер или же написать свой"))
```

2) Описание, какие сервисы запускаются в AppManager:

```swift
public func configuration(application: UIApplication,
                          launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                          userAcquisitionServer: UserAcquisition.Urls = .inapps,
			  configurationGoogleAds: Bool = false) {
        
   FacebookService().configuration(launchOptions: launchOptions)
   SearchAdsService().configuration()
   YandexService().configuration()
        
   UserAcquisitionManager.shared.configure(withAPIKey: GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                                                    by: .userAcquisitionKey) as? String ?? "",
                                           urlRequest: userAcquisitionServer)
   UserAcquisitionManager.shared.conversionInfo.fbAnonymousId = AppEvents.anonymousID
        
   StoreManager.shared.configuration()
   if configurationGoogleAds {
      GoogleAdsManager.shared.configuration()
   }
   SKAdNetwork.registerAppForAdNetworkAttribution()
}
```

## TrackingTransparencyManager
1) Для запуска Firebase, FirebaseRemoteConfig, AppsFlyer, ATT, вы должны вызвать в AppDelegate:

```swift
TrackingTransparencyManager().configuration(isStartFirebase: "Флаг на запуск Firebase", 
					    isStartRemoteConfig: "Флаг на запуcк FirebaseRemoteConfig") {
   "Тут устанавливаете запуск первого экрана"    
}
```

2) Для запуска первого экрана, вы должны описать функцию, а после вызывать ее в блоке выше:

```swift
internal func startScreen() {
   let vc = UIStoryboard.init(name: "Наименование вашего Storyboard", bundle: nil).instantiateInitialViewController()!
   window = UIWindow(frame: UIScreen.main.bounds)
   window?.rootViewController = vc
   window?.makeKeyAndVisible()
}
```

## Стэк Pods которые присутствуют:

```
pod 'lottie-ios'
pod 'NVActivityIndicatorView'
pod 'DeviceKit'
pod 'SwiftyStoreKit'
pod 'Firebase'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/RemoteConfig'
pod 'FBSDKCoreKit'
pod 'FBAudienceNetwork'
pod 'YandexMobileMetrica'
pod 'AppsFlyerFramework'
pod 'Google-Mobile-Ads-SDK'
pod 'GoogleMobileAdsMediationIronSource'
pod 'GoogleMobileAdsMediationAdColony'
pod 'GoogleMobileAdsMediationAppLovin'
pod 'GoogleMobileAdsMediationFacebook'
pod 'GoogleMobileAdsMediationUnity'
pod 'GoogleMobileAdsMediationTapjoy'
pod 'GoogleMobileAdsMediationVungle'
```
