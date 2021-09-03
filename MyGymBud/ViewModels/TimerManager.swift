//
//  TimerManager.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/12/21.
//

import SwiftUI
import AVFoundation

class TimerManager: ObservableObject {
    let tickingSystemSoundID: SystemSoundID = 1054
    let startExercisingSystemSoundID: SystemSoundID = 1013
    
    @Published var mode: timerMode = .paused
    @Published var secondsRemaining = 0
    
    private var timer = Timer()
    var timeRemaining: String {
        let min = self.secondsRemaining / 60
        let sec = self.secondsRemaining % 60
        return String(format: "%02d : %02d", min, sec)
    }
    
    func start(soundOn: Bool) {
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.secondsRemaining -= 1
            if soundOn && self.secondsRemaining <= 3 && self.secondsRemaining >= 1 {
                AudioServicesPlaySystemSound(self.tickingSystemSoundID)
            }
            if self.secondsRemaining == 0 {
                if soundOn {
                    AudioServicesPlaySystemSound(self.startExercisingSystemSoundID)
                }
                self.stop()
            }
            if self.secondsRemaining < 0 {
                self.stop()
            }
        }
    }
    
    func stop() {
        timer.invalidate()
        secondsRemaining = 0
        mode = .stopped
    }
    
    func pause() {
        timer.invalidate()
        mode = .paused
    }
    
    enum timerMode {
        case running
        case stopped
        case paused
    }
}
