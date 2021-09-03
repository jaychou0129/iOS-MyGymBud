//
//  MainView.swift
//  MyGymBud
//
//  Created by Jay Chou on 5/30/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    var body: some View {
        
        return TabView(selection: $stateManager.selectedTab) {
            CategoriesView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.walk")
                }
                .tag(0)
            LogView()
                .tabItem {
                    Label("Log", systemImage: "calendar")
                }
                .tag(1)
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }.tag(3)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
    }
}
