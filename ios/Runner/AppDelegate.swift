import AuthenticationServices
import Flutter
import ObjectiveC
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GoogleSignInConsentDialog.disable()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

/// Google Sign-In opens an iOS web sign-in session. iOS shows
/// "Wants to Use accounts.google.com to Sign In" unless that session is
/// private. A private session skips the alert. Google's own account page
/// still appears.
private enum GoogleSignInConsentDialog {
  private static var didDisable = false

  static func disable() {
    guard !didDisable else { return }
    let sessionClass: AnyClass = ASWebAuthenticationSession.self
    let original = #selector(ASWebAuthenticationSession.start)
    let replacement = #selector(ASWebAuthenticationSession.whyse_startSkippingConsent)
    guard
      let originalMethod = class_getInstanceMethod(sessionClass, original),
      let replacementMethod = class_getInstanceMethod(sessionClass, replacement)
    else { return }
    method_exchangeImplementations(originalMethod, replacementMethod)
    didDisable = true
  }
}

private extension ASWebAuthenticationSession {
  @objc func whyse_startSkippingConsent() -> Bool {
    prefersEphemeralWebBrowserSession = true
    return whyse_startSkippingConsent()
  }
}
