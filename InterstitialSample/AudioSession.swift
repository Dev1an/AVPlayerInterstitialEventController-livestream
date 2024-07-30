import AVKit

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
                
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true, options: [])
            print("Setting category to AVAudioSessionCategoryPlayback.")
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.", error)
        }
        
        return true
    }
}
#endif
