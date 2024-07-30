//
//  InterstitialSampleApp.swift
//  InterstitialSample
//
//  Created by Damiaan Dufaux on 30/07/2024.
//

import SwiftUI

@main
struct InterstitialSampleApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
