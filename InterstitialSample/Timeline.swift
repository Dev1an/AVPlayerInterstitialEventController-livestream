import Observation
import AVKit

extension AdPlayer {
    class Timeline: ObservableObject {
        @Published var primaryPlayhead: Date = .now
        @Published var interstitialPlayhead: Date = .now
        @Published var tracks = [String: Properties]()
        
        struct Properties {
            let start: Date
            var duration: Double
        }
    }
}

extension AdPlayer.Timeline {
    class Observer {
        let timeline: AdPlayer.Timeline
        let observation: Timer
        
        init(primary: AVPlayerItem, interstitialMonitor: AVPlayerInterstitialEventController) {
            let t = AdPlayer.Timeline()
            timeline = t
            observation = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if t.tracks.values.count > interstitialMonitor.events.count {
                    print("missing ads", t.tracks.values.count, interstitialMonitor.events.count)
                }
                if let primaryDate = primary.currentDate() {
                    DispatchQueue.main.async {
                        t.primaryPlayhead = primaryDate
                    }
                }
                if let event = interstitialMonitor.currentEvent, let date = event.date {
                    DispatchQueue.main.async {
                        t.interstitialPlayhead = date.addingTimeInterval(interstitialMonitor.interstitialPlayer.currentTime().seconds)
                    }
                }
            }
        }
        
        deinit {
            observation.invalidate()
        }
    }
}
