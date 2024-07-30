import AVKit

let repeatingUrl = URL(string: "http://localhost:8080/manifest.m3u8")!
let adUrl = URL(string: "https://cdn.theoplayer.com/demos/ads/videos/midroll.mp4")!

class AdPlayer {
    let internalPlayer = AVPlayer()
    let interstitialController: AVPlayerInterstitialEventController
    let playerItem = AVPlayerItem(url: repeatingUrl)
    let timelineObserver: Timeline.Observer
    let daterangeCollector = AVPlayerItemMetadataCollector(identifiers: nil, classifyingLabels: nil)
    let daterangeCollectorDelegate: DaterangeCollectorDelegate
    let daterangeCollectorQueue = DispatchQueue.main
    var ads = [AVPlayerInterstitialEvent]() {
        didSet {  }
    }
    
    init() {
        internalPlayer.replaceCurrentItem(with: playerItem)
        interstitialController = .init(primaryPlayer: internalPlayer)
        timelineObserver = Timeline.Observer(primary: playerItem, interstitialMonitor: interstitialController)
        
        daterangeCollectorDelegate = DaterangeCollectorDelegate(
            item: playerItem,
            interstitialController: interstitialController,
            timeline: timelineObserver.timeline
        )
        daterangeCollector.setDelegate(daterangeCollectorDelegate, queue: daterangeCollectorQueue)
        playerItem.add(daterangeCollector)
    }
    
    var timeline: Timeline { timelineObserver.timeline }
        
    func seekBackward() {
        let now = internalPlayer.currentTime()
        internalPlayer.seek(to: now - .init(seconds: 15, preferredTimescale: now.timescale))
    }
    
    func seekForward() {
        let now = internalPlayer.currentTime()
        internalPlayer.seek(to: now + .init(seconds: 15, preferredTimescale: now.timescale))
    }
    
    class DaterangeCollectorDelegate: NSObject, AVPlayerItemMetadataCollectorPushDelegate {
        let item: AVPlayerItem
        let interstitialController: AVPlayerInterstitialEventController
        let timeline: Timeline
        
        init(item: AVPlayerItem, interstitialController: AVPlayerInterstitialEventController, timeline: Timeline) {
            self.item = item
            self.interstitialController = interstitialController
            self.timeline = timeline
        }
        
        func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
            for index in indexesOfNewGroups.union(indexesOfModifiedGroups) {
                let adInfo = metadataGroups[index]
                
                let adItem = AVPlayerItem(url: adUrl)
                let id = UUID().uuidString
                let ad = AVPlayerInterstitialEvent(
                    primaryItem: self.item,
                    identifier: id,
                    date: adInfo.startDate,
                    templateItems: [adItem],
                    resumptionOffset: .init(seconds: 10, preferredTimescale: item.duration.timescale)
                )
                ad.restrictions = [.constrainsSeekingForwardInPrimaryContent, .requiresPlaybackAtPreferredRateForAdvancement]
                print("adding ad", id, adInfo.startDate)
                self.interstitialController.events.append(ad)
                self.timeline.tracks[id] = .init(start: adInfo.startDate, duration: 10)
            }
        }
    }
}
