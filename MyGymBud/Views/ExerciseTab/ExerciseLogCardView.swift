//
//  ExerciseLogCardView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/15/21.
//

import SwiftUI

struct ExerciseLogCardView: View {
    @EnvironmentObject var data: MGBData
    
    let exercise: Exercise
    let log: Log
    
    var body: some View {
        HStack {
            let displayStyle = (exercise.mode == .Weight) ? data.appConfig.weightLogDisplayModeInExerciseView : data.appConfig.timedLogDisplayModeInExerciseView
            
            LogMainContent(log: log, mode: exercise.mode, displayMode: displayStyle)
                    
            Spacer()
            Text(log.date.disp(data.appConfig.dateDisplayMode))
                .font(.footnote)
        }
    }
}

struct ExerciseLogCardView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseLogCardView(exercise: Category.sampleData[0].exercises[0], log: Log(eID: Category.sampleData[0].exercises[0].id, weightLogs: [
            WeightLog(weight: Weight(25, .KG), reps: [Repetition(reps: 15, sets: 3), Repetition(reps: 10, sets: 2)]),
            WeightLog(weight: Weight(15, .KG), reps: [Repetition(reps: 15, sets: 4)])
        ]))
            .environmentObject(MGBData())
    }
}

