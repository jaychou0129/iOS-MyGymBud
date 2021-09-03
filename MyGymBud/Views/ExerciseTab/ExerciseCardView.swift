//
//  ExerciseCardView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/7/21.
//

import SwiftUI

struct ExerciseCardView: View {
    @EnvironmentObject var data: MGBData
    
    let exercise: Exercise
    
    @State private var highestDisplayText = ""
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(exercise.enabled ? .none : .secondary)
            
                let tagsString = exercise.tags.joined(separator: ", ")
                if !tagsString.isEmpty {
                    HStack {
                        Image(systemName: "tag")
                        Text(tagsString).font(.caption)
                    }
                }
                
                Text(highestDisplayText)
                    .font(.caption)
                    .padding(.top, 1.0)
                    .isHidden((exercise.mode == .Weight && !data.appConfig.weightShowBest) ||
                            (exercise.mode == .Timed && !data.appConfig.timedShowBest))
            }
            Spacer()
            if !exercise.enabled {
                Image(systemName: "eye.slash")
            }
        }
        .onAppear(perform: initializeHighestDisplayText)
        
    }
    
    private func initializeHighestDisplayText() {
        if exercise.maxExists {
            highestDisplayText = "Best: "
            if let maxWeightLog = exercise.maxWeightLog {
                highestDisplayText += "\(maxWeightLog.weight.disp()) \(maxWeightLog.reps[0].disp())"
            }
            if let maxTimedLog = exercise.maxTimedLog {
                highestDisplayText += "\(maxTimedLog.disp())"
            }
            highestDisplayText += " (\(exercise.maxDate!.disp(data.appConfig.dateDisplayMode)))"
        } else if exercise.mode != .Routine {
            highestDisplayText = "Best: No record"
        }
    }
}

struct ExerciseCardView_Previews: PreviewProvider {

    static var previews: some View {
        let category = Category.sampleData[0]
        ExerciseCardView(exercise: category.exercises[0])
            .background(category.color)
            .foregroundColor(category.color.accessibleFontColor)
            .previewLayout(.sizeThatFits)
            .environmentObject(MGBData())
    }
}
