//
//  TestSound.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/12/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var data: MGBData
    @State private var showResetWarning = false
    
    var body: some View {
        NavigationView {
            List {
                SoundSettings
                WeightLogSettings
                TimedLogSettings
                //CalendarSettings
                DateSettings
                ResetAllSettings
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var SoundSettings: some View {
        Section(header: Text("Sound"), footer: Text("If your phone is on mute already, turning off the timer sound turns off the vibration when time is almost up.").padding(.bottom)) {
            Toggle("Timer Sound On", isOn: $data.appConfig.soundOn)
        }
    }
    
    private var WeightLogSettings: some View {
        Section(header: Text("Weight log display options")) {
            Picker("Calendar", selection: $data.appConfig.weightLogDisplayMode) {
                Text("Show all reps & sets").tag(AppConfiguration.LogDisplayMode.showAll)
                Text("Show first set").tag(AppConfiguration.LogDisplayMode.showFirst)
                Text("Show last set").tag(AppConfiguration.LogDisplayMode.showLast)
                Text("Show maximum weight").tag(AppConfiguration.LogDisplayMode.showMaxIntensity)
                Text("Show training volume").tag(AppConfiguration.LogDisplayMode.showVolume)
            }
            Picker("Exercise View", selection: $data.appConfig.weightLogDisplayModeInExerciseView) {
                Text("Show all reps & sets").tag(AppConfiguration.LogDisplayMode.showAll)
                Text("Show first set").tag(AppConfiguration.LogDisplayMode.showFirst)
                Text("Show last set").tag(AppConfiguration.LogDisplayMode.showLast)
                Text("Show maximum weight").tag(AppConfiguration.LogDisplayMode.showMaxIntensity)
                Text("Show training volume").tag(AppConfiguration.LogDisplayMode.showVolume)
            }
            Picker("Charts", selection: $data.appConfig.weightLogChartMode) {
                Text("Graph first set").tag(AppConfiguration.LogDisplayMode.showFirst)
                Text("Graph last set").tag(AppConfiguration.LogDisplayMode.showLast)
                Text("Graph maximum weight").tag(AppConfiguration.LogDisplayMode.showMaxIntensity)
                Text("Graph training volume").tag(AppConfiguration.LogDisplayMode.showVolume)
            }
            Picker("Chart Default Unit", selection: $data.appConfig.weightLogChartDefaultUnit) {
                Text("Kilograms").tag(Weight.Unit.KG)
                Text("Pounds").tag(Weight.Unit.LBS)
            }
            Toggle("Show Best Record", isOn: $data.appConfig.weightShowBest)
        }
    }
    
    private var TimedLogSettings: some View {
        Section(header: Text("Timed log display options")) {
            Picker("Calendar", selection: $data.appConfig.timedLogDisplayMode) {
                Text("Show all reps & sets").tag(AppConfiguration.LogDisplayMode.showAll)
                Text("Show first set").tag(AppConfiguration.LogDisplayMode.showFirst)
                Text("Show last set").tag(AppConfiguration.LogDisplayMode.showLast)
                Text("Show maximum time").tag(AppConfiguration.LogDisplayMode.showMaxIntensity)
                Text("Show training volume").tag(AppConfiguration.LogDisplayMode.showVolume)
            }
            Picker("Exercise View", selection: $data.appConfig.timedLogDisplayModeInExerciseView) {
                Text("Show all reps & sets").tag(AppConfiguration.LogDisplayMode.showAll)
                Text("Show first set").tag(AppConfiguration.LogDisplayMode.showFirst)
                Text("Show last set").tag(AppConfiguration.LogDisplayMode.showLast)
                Text("Show maximum time").tag(AppConfiguration.LogDisplayMode.showMaxIntensity)
                Text("Show training volume").tag(AppConfiguration.LogDisplayMode.showVolume)
            }
            Picker("Charts", selection: $data.appConfig.timedLogChartMode) {
                Text("Graph first set").tag(AppConfiguration.LogDisplayMode.showFirst)
                Text("Graph last set").tag(AppConfiguration.LogDisplayMode.showLast)
                Text("Graph maximum time").tag(AppConfiguration.LogDisplayMode.showMaxIntensity)
                Text("Graph training volume").tag(AppConfiguration.LogDisplayMode.showVolume)
            }
            Picker("Chart Default Unit", selection: $data.appConfig.timedLogChartDefaultUnit) {
                Text("Minutes").tag(Time.Component.MIN)
                Text("Seconds").tag(Time.Component.SEC)
            }
            Toggle("Show Best Record", isOn: $data.appConfig.timedShowBest)
        }
    }
    
    private var CalendarSettings: some View {
        Section(header: Text("Calendar display options")) {
            Picker("Logs", selection: $data.appConfig.calendarDisplayContinuous) {
                Text("Continuous").tag(true)
                Text("Daily").tag(false)
            }
        }
    }
    
    private var DateSettings: some View {
        Section(header: Text("Date display options")) {
            Picker("Date Format", selection: $data.appConfig.dateDisplayMode) {
                Text("Full Numeric - \(Date().disp(.numeric))").tag(AppConfiguration.DateDisplayMode.numeric)
                Text("Short - \(Date().disp(.textShort))").tag(AppConfiguration.DateDisplayMode.textShort)
                Text("Medium - \(Date().disp(.textMedium))").tag(AppConfiguration.DateDisplayMode.textMedium)
                Text("Long - \(Date().disp(.textLong))").tag(AppConfiguration.DateDisplayMode.textLong)
            }
        }
    }
    
    private var ResetAllSettings: some View {
        Section {
            Button(action: {
                showResetWarning = true
            }) {
                Text("Reset All Settings")
                    .foregroundColor(.red)
            }
        }
        .actionSheet(isPresented: $showResetWarning) {
            ActionSheet(
                title: Text("Warning"),
                message: Text("Are you sure you want to reset all settings?"),
                buttons: [
                    .destructive(
                    Text("Reset All Settings"),
                    action: {
                        data.resetAllSettings()
                    }),
                    .cancel()
            ])
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(MGBData())
    }
}
