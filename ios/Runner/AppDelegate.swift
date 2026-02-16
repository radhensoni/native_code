import UIKit
import Flutter
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
        name: "com.example.native_code/native",
        binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard call.method == "vibrate" else {
        result(FlutterMethodNotImplemented)
        return
      }
      
      if let args = call.arguments as? [String: Any],
         let pattern = args["pattern"] as? [Int] {
          self?.vibrateWithPattern(pattern)
          result(true)
      } else {
          result(FlutterError(
              code: "INVALID_PATTERN",
              message: "Pattern is invalid or missing",
              details: nil
          ))
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func vibrateWithPattern(_ pattern: [Int]) {
    DispatchQueue.global(qos: .userInitiated).async {
        for (index, duration) in pattern.enumerated() {
            if index % 2 == 0 {
                // Wait (even indices are delays)
                usleep(useconds_t(duration * 1000))
            } else {
                // Vibrate (odd indices are vibrations)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                usleep(useconds_t(duration * 1000))
            }
        }
    }
  }
}