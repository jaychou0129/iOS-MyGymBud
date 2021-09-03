//
//  LogConfiguration.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import Foundation

class LogConfiguration: ObservableObject {
    @Published var weight: Weight = Weight()
    @Published var reps: Int = 1
    @Published var time: Time = Time()
    @Published var restTime: Time = Time()
    
    func initialize(fromExercise exercise: Exercise) -> Void {
        if exercise.mode == .Weight {
            self.weight = exercise.defaultWeight
            self.reps = exercise.defaultReps
        } else if exercise.mode == .Timed {
            self.time = exercise.defaultTime
        }
        
        self.restTime = exercise.defaultRestTime
    }
}
