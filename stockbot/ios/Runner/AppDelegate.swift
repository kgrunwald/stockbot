import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    application.isStatusBarHidden = false;
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        let imageView = UIImageView(frame: self.window!.bounds)
        imageView.tag = 101
        imageView.backgroundColor = UIColor.init(red: 90 / 255.0, green: 100 / 255.0, blue: 251 / 255.0, alpha: 1)
        imageView.contentMode = .center
        imageView.image = UIImage.init(named: "robot.png")
        UIApplication.shared.keyWindow?.subviews.last?.addSubview(imageView)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        if let imageView : UIImageView = UIApplication.shared.keyWindow?.subviews.last?.viewWithTag(101) as? UIImageView {
            imageView.removeFromSuperview()
        }
    }
}
