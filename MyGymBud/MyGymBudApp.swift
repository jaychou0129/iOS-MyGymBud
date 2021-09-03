//
//  MyGymBudApp.swift
//  MyGymBud
//
//  Created by Jay Chou on 5/29/21.
//

import SwiftUI

@main
struct MyGymBudApp: App {
    @StateObject private var data = MGBData()
    @StateObject private var stateManager = StateManager()
    @State private var showLaunchView = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainView()
                    .environmentObject(data)
                    .environmentObject(stateManager)
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                    }
                }
                .zIndex(2.0)
            }
        }
    }
}
