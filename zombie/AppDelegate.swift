import Foundation
import AppKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // swiftlint: disable line_length
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        setupMyApp()
        return true
    }

    private func setupMyApp() {
        // TODO: Add any intialization steps here.
        NSLog("Application started up!")
    }
}
