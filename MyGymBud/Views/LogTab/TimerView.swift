//
//  TimerView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/11/21.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var config: LogConfiguration
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var stateManager: StateManager
    @EnvironmentObject var data: MGBData
    
    @Binding var log: Log.Data
    let mode: Mode
    
    @State private var state: TimerState = .SETTING
    @State private var timerPreviousMode: TimerManager.timerMode = .paused
    @State private var timerPreviousTime: Date = Date()
    
    private enum TimerState {
        case SETTING
        case EXERCISING
        case RESTING
    }
    
    var body: some View {
        Group {
            switch (self.state) {
            case .SETTING:
                TimerSettingView
            case .EXERCISING:
                TimerExercisingView
            case .RESTING:
                TimerRestingView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            // Application entering background
            timerPreviousTime = Date()
            timerPreviousMode = timerManager.mode
            timerManager.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if timerPreviousMode == .running {
                timerManager.secondsRemaining -= Int(Date().timeIntervalSince(timerPreviousTime))
                if timerManager.secondsRemaining < 0 {
                    timerManager.stop()
                } else {
                    timerManager.start(soundOn: data.appConfig.soundOn)
                }
            }
        }
    }
    
    var TimerExercisingView: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: 24, antialiased: true)
                .foregroundColor(.green)
            VStack {
                Text("Exercising")
                    .font(.headline)
                
                if mode == .Weight {
                    Text("\(config.weight.disp()) × \(config.reps)")
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .onTapGesture {
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    HStack (spacing: 30){
                        Button (action: {
                            vibrate(style: .medium)
                            if log.weightLogs.isEmpty || log.weightLogs.last!.weight != config.weight {
                                log.weightLogs.append(WeightLog(weight: config.weight, reps: [Repetition(reps: config.reps, sets: 1)]))
                            } else if log.weightLogs.last!.reps.last!.reps != config.reps {
                                log.weightLogs[log.weightLogs.count - 1].reps.append(Repetition(reps: config.reps, sets: 1))
                            } else {
                                log.weightLogs[log.weightLogs.count - 1].reps[log.weightLogs[log.weightLogs.count - 1].reps.count - 1].sets += 1
                            }
                            
                            state = .RESTING
                        }) {
                            Text("Complete set")
                        }
                    }
                }
                
                if mode == .Timed {
                    Text("\(config.time.dispText())")
                        .font(.headline)
                    Text("\(timerManager.timeRemaining)")
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .onTapGesture {
                            //timerManager.pause()
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    HStack (spacing: 30){
                        Button (action: {
                            if timerManager.mode == .running { timerManager.pause()
                            } else {
                                timerManager.start(soundOn: data.appConfig.soundOn)
                            }
                        }) {
                            Text(timerManager.mode == .running ? "Pause" : "Resume")
                        }
                        Button (action: {
                            vibrate(style: .medium)
                            if log.timedLogs.isEmpty || log.timedLogs.last!.time != config.time {
                                log.timedLogs.append(TimedLog(time: config.time, sets: 1))
                            } else {
                                log.timedLogs[log.timedLogs.count - 1].sets += 1
                            }
                            timerManager.stop()
                            state = .RESTING
                            
                        }) {
                            Text("Complete set")
                        }
                    }
                }
            }
        }
        .onAppear {
            if mode == .Timed && !config.time.isZero() {
                timerManager.secondsRemaining = config.time.value
                timerManager.start(soundOn: data.appConfig.soundOn)
            }
        }
        .onChange(of: timerManager.mode) { _ in
            if timerManager.mode == .stopped { // time's up
                vibrate(style: .medium)
                if log.timedLogs.isEmpty || log.timedLogs.last!.time != config.time {
                    log.timedLogs.append(TimedLog(time: config.time, sets: 1))
                } else {
                    log.timedLogs[log.timedLogs.count - 1].sets += 1
                }
                timerManager.stop()
                state = .RESTING
            }
        }
        .onChange(of: config.time) { _ in
            timerManager.pause()
            timerManager.secondsRemaining = config.time.value
        }
    }
    
    var TimerSettingView: some View {
        ZStack {
            if mode == .Weight {
                Circle()
                    .strokeBorder(lineWidth: 24, antialiased: true)
                    .foregroundColor(.gray)
                VStack {
                    Text("Set Weight")
                        .font(.headline)
                    Text("\(config.weight.disp()) × \(config.reps)")
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .onTapGesture {
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    Button (action: {state = .EXERCISING}) {
                        Text("Start")
                    }
                }
            }
            if mode == .Timed {
                Circle()
                    .strokeBorder(lineWidth: 24, antialiased: true)
                    .foregroundColor(.yellow)
                VStack {
                    Text("Set Time")
                        .font(.headline)
                    Text("\(config.time.dispTimer())")
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .onTapGesture {
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    Button (action: {state = .EXERCISING}) {
                        Text("Start")
                    }
                }
            }
        }
    }
    
    var TimerRestingView: some View {
        
        ZStack {
            /*let timePassed = config.restTime.isZero() ? 1 : config.restTime.value - timerManager.secondsRemaining
            let totalTime = config.restTime.isZero() ? 1 : config.restTime.value
            ProgressArc(progress: timePassed, total: totalTime)
                .rotation(Angle(degrees: -90))
                .stroke(Color.yellow, lineWidth: 12)*/
            Circle()
                .strokeBorder(lineWidth: 24, antialiased: true)
                .foregroundColor(.yellow)
            VStack {
                if config.restTime.isZero() {
                    Text("Rest Timer is disabled")
                        .font(.subheadline)
                        .onTapGesture {
                            //timerManager.pause()
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    Text("Resting")
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .onTapGesture {
                            //timerManager.pause()
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    Button (action: {
                        state = .EXERCISING
                    }) {
                        Text("Continue Exercising")
                    }
                } else {
                    Text("Resting")
                        .font(.headline)
                    Text("\(timerManager.timeRemaining)")
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .onTapGesture {
                            //timerManager.pause()
                            stateManager.presentingNewLogConfigSheet = true
                        }
                    
                    HStack (spacing: 30){
                        Button (action: {
                            if timerManager.mode == .running { timerManager.pause()
                            } else {
                                timerManager.start(soundOn: data.appConfig.soundOn)
                            }
                        }) {
                            if timerManager.mode == .running { Text("Pause")
                            } else {
                                Text("Resume")
                            }
                            
                        }
                        Button (action: {
                            timerManager.stop()
                            state = .EXERCISING
                        }) {
                            Text("Skip")
                        }
                    }
                }
            }
        }
        .onAppear {
            if !config.restTime.isZero() {
                timerManager.secondsRemaining = config.restTime.value
                timerManager.start(soundOn: data.appConfig.soundOn)
            }
        }
        .onChange(of: timerManager.mode) { _ in
            if timerManager.mode == .stopped { // time's up
                state = .EXERCISING
            }
        }
        .onChange(of: config.restTime) { _ in
            timerManager.pause()
            timerManager.secondsRemaining = config.restTime.value
        }
    }
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) -> Void {
        let impactMed = UIImpactFeedbackGenerator(style: style)
        impactMed.impactOccurred()
    }
}
