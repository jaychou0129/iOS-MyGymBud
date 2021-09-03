//
//  NewLogExerciseSelector.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/27/21.
//

import SwiftUI

struct NewLogExerciseSelector: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    let category: Category
    let date: Date
    
    var body: some View {
        List {
            ForEach(category.exercises.filter{ $0.enabled }.sorted()) { exercise in
                NavigationLink(destination: NewLogExerciseView(exercise: binding(forExercise: exercise, in: category), date: date)) {
                    ExerciseCardView(exercise: exercise)
                        .foregroundColor(category.color.accessibleFontColor)
                }
                .listRowBackground(category.color)
            }
        }
        .padding()
        .navigationTitle(category.name)
    }
    
    private func binding(forExercise ex: Exercise, in cat: Category) -> Binding<Exercise> {
        guard let indices = data.findExerciseIndices(category: cat, exercise: ex) else {
            fatalError("Can't find exercise")
        }
        
        return $data.categories[indices.categoryIndex].exercises[indices.exerciseIndex]
    }
}
