# Usage

## CocoaPods Install
Add ```pod 'CRGeneralManager', :git => "https://github.com/AlCreatex/CRGeneralManager.git"``` to your Podfile. "CRGeneralManager" is the name of the library.


## Organic or Not Organic 
1. Свойство через которое можно определять, показать орагнический экран или же не органический:

```swift
UserDefaultsProperties.isStartNowAppsFlyer
```


## GoogleAdsManager
1. При первом запуске приложения, вы можете вызвать configuration, **НО ЕСЛИ ВЫ ЗАПУСКАЕТЕ AppManager, ВЫ МОЖЕТЕ ПРОПУСТИТЬ ЭТОТ ПУНКТ**:

```swift
GoogleAdsManager.shared.configuration()
```

2. Для вызова interstitial рекламы:

```swift
GoogleAdsManager.shared.presentInterstitial(viewController: self) {
   "Ваши действия, после того как реклама закроется или же произойдет ошибка загрузки рекламы"
}
```

3. Для вызова rewarded рекламы:

```swift
GoogleAdsManager.shared.presentRewarded(viewController: self) {
   "Ваши действия, после того как реклама закроется или же произойдет ошибка загрузки рекламы"
} userDidEarnRewardHandler: {
   "Ваши действия, после того как реклама закончится, чем наградить пользователя"     
}
```

4. Для вызова banner рекламы:

Вам потребуется создать IBOutlet или же создать обьект через код, и поместить его во входной параметр bannerView.
```swift
GoogleAdsManager.shared.present(bannerView: GADBannerView, viewController: self)
```


## StoreManager
1. При первом запуске приложения, вы можете вызвать configuration, **НО ЕСЛИ ВЫ ЗАПУСКАЕТЕ AppManager, ВЫ МОЖЕТЕ ПРОПУСТИТЬ ЭТОТ ПУНКТ**:

```swift
StoreManager.shared.configuration()
```

2. Далее внутри приложения для офрмления покупки/подписки или же ее восстановления, вы должны вызвать:

2.1 Оформление покупки/подписки и тестирование внутреннего статуса isActive:
```swift
StoreManager.shared.purchase(product: "Пишем ключ из ProductList", isTestingMode: Bool) { (result) in
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

2.2 Восстановление покупки/подписки:
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
2.3 Получение информации о покупке/подписке:
```swift
StoreManager.shared.rectriveInfo(productBundle: "Bundle вашей покупки или подписки") { (product) in
   "Ваши действия, после когда вы получите продукт"
}
```

3. **В StoreManager все события для аналитики присутствуют, дополнительно при вызове методов их прописывать не надо.**


## AnalyticsManager
1. Для отправки ивента, вы должны вызвать:

```swift
AnalyticsManager.trackWith(eventName: .init(rawValue: "Выбрать из списка нужный вам ивент или же написать свой"))
```

2. Отправлять ивент по успешной подписке как и отмене покупки не требуется, это уже прописано внутри StoreManager.


## AppManager
1. Для запуска всех сервисов, вы должны вызывать в AppDelegate:

```swift
AppManager().configuration(application: application, 
			   launchOptions: launchOptions, 
			   isLaunchFirebase: Bool,
			   userAcquisitionServer: .init(rawValue: "Выбрать из списка нужный вам сервер или же написать свой"))
```

2. Описание, какие сервисы запускаются в AppManager:

```swift
public func configuration(application: UIApplication,
                          launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
			  isLaunchFirebase: Bool,
                          userAcquisitionServer: UserAcquisition.Urls = .inapps) {
        
   FirebaseSerivce().configuration(isLaunchFirebase: isLaunchFirebase)
   FacebookService().configuration()
   SearchAdsService().configuration()
   YandexService().configuration()
        
   UserAcquisitionManager.shared.configure(withAPIKey: GettingsKeysFromPlist.getKey(from: Constants.NameFile.remoteConfig,
                                                                                    by: .userAcquisitionKey) as? String ?? "",
                                           urlRequest: userAcquisitionServer)
   UserAcquisitionManager.shared.conversionInfo.fbAnonymousId = AppEvents.anonymousID
        
   StoreManager.shared.configuration()
   GoogleAdsManager.shared.configuration()
   SKAdNetwork.registerAppForAdNetworkAttribution()
}
```


## TrackingTransparencyManager
1. Для запуска AppsFlyer, ATT, вы должны вызвать в AppDelegate:

```swift
TrackingTransparencyManager.shared.configuration()
```

2. Для вызова ATT внутри приложения, вы должны вызвать:

```swift
TrackingTransparencyManager.shared.setupInsideAppATT()
```


## NVActivityIndicatorView
1. Для начала имплементируйте протокол к вашему классу:

```swift
class NameController: UIViewController, ActivityIndicatorProtocol
```

2. Для установки стартовых параметров, во ViewDidLoad вызовите: 

```swift
setupActivityIndicator(type: NVActivityIndicatorType)
```

3. Для старта и остановки анимации, вызывайте методы:

```swift
startAnimation()
stopAnimation()
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
