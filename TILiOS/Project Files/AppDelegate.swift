import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    if Auth().token == nil {
      let rootController = UIStoryboard(name: "Login", bundle: Bundle.main)
        .instantiateViewController(withIdentifier: "LoginNavigation")
      window?.rootViewController = rootController
    }
    return true
  }
}
