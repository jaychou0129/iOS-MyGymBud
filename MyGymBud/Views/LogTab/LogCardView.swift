//
//  LogCardView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/1/21.
//

import SwiftUI

struct LogCardView: View {
    @EnvironmentObject var data: MGBData
    let exercise: Exercise
    let log: Log
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(exercise.enabled ? .none : .secondary)
                
                let displayStyle = (exercise.mode == .Weight) ? data.appConfig.weightLogDisplayMode : data.appConfig.timedLogDisplayMode
                
                LogMainContent(log: log, mode: exercise.mode, displayMode: displayStyle)
            }
            Spacer()
            Text(log.date.dispTime()).font(.footnote)
        }
    }
}

struct LogCardView_Previews: PreviewProvider {
    static var previews: some View {
        LogCardView(exercise: Category.sampleData[0].exercises[0], log: Log(eID: Category.sampleData[0].exercises[0].id, weightLogs: [
            WeightLog(weight: Weight(25, .KG), reps: [Repetition(reps: 15, sets: 3), Repetition(reps: 10, sets: 2)]),
            WeightLog(weight: Weight(15, .KG), reps: [Repetition(reps: 15, sets: 4)])
        ]))
            .environmentObject(MGBData())
    }
}
