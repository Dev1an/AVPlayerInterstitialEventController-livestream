//
//  ContentView.swift
//  InterstitialSample
//
//  Created by Damiaan Dufaux on 30/07/2024.
//

import SwiftUI
import AVKit
import Charts
import RepeatingHls

struct ContentView: View {
    @State var duration: Double?
    @State var server = ServerState.loading
    
    var body: some View {
        VStack {
            switch server {
            case .loading:
                Text("Loading HLS server")
            case .loaded(_, let player):
                VideoPlayer(player: player.internalPlayer)
                    .aspectRatio(16/9, contentMode: .fit)
                HStack {
                    Button("", systemImage: "gobackward.15", action: player.seekBackward)
                    Button("", systemImage: "play.fill", action: player.internalPlayer.play)
                    Button("", systemImage: "pause.fill", action: player.internalPlayer.pause)
                    Button("", systemImage: "goforward.15", action: player.seekForward)
                }.font(.title)
                TimelineView(timeline: player.timelineObserver.timeline)
            case .error(let error):
                Text("Error" + error.localizedDescription)
            }
        }
        .padding()
        .task {
            do {
                let s = try await SwifterServer()
                try s.start()
                let player = AdPlayer()
                server = .loaded(s, player)
                player.internalPlayer.play()
            } catch {
                server = .error(error)
            }
        }
    }
    
    enum ServerState {
        case loading
        case loaded(SwifterServer, AdPlayer)
        case error(Error)
    }
}

struct TimelineView: View {
    @StateObject var timeline: AdPlayer.Timeline
    
    var body: some View {
        Text("\(timeline.primaryPlayhead, format: .dateTime.hour().minute().second().secondFraction(.fractional(3)))")
        Chart {
            RuleMark(
                x: .value("primary playhead", timeline.primaryPlayhead)
            ).foregroundStyle(by: .value("playhead", "Primary"))
            RuleMark(
                x: .value("interst playhead", timeline.interstitialPlayhead)
            ).foregroundStyle(by: .value("playhead", "Ad"))
            ForEach(Array(timeline.tracks.keys), id: \.self) { id in
                let track = timeline.tracks[id]!
                BarMark(
                    xStart: .value("start", track.start),
                    xEnd: .value("end", track.start + track.duration)
                ).foregroundStyle(by: .value("playhead", "Ad")).opacity(0.5)
            }
        }
    }
}

#Preview {
    ContentView()
}
