//
//  CategoryView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/7/21.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @Binding var category: Category
    
    @State private var newExerciseData = Exercise.Data()
    
    var body: some View {
        VStack {
            if category.exercises.isEmpty {
                Text("This category currently has no exercises.")
                    .font(.caption)
                    .padding(.top)
            }
            List {
                ForEach(category.exercises.sorted()) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: binding(for: exercise)), tag: exercise.id, selection: $stateManager.presentingExerciseID) {
                        ExerciseCardView(exercise: exercise)
                            .foregroundColor(category.color.accessibleFontColor)
                    }
                    .listRowBackground(category.color)
                }
            }
            .padding(.horizontal)
            .navigationTitle(category.name)
            .navigationBarItems(trailing: Button("New Exercise", action: {
                newExerciseData = Exercise.Data()
                stateManager.creatingNewExercise = true
            }))
            .fullScreenCover(isPresented: $stateManager.creatingNewExercise) {
                NavigationView {
                    ExerciseEditView(exerciseData: $newExerciseData)
                        .navigationBarItems(leading: Button("Cancel") {
                            stateManager.dismissNewExercise()
                        }, trailing: Button("Save") {
                            stateManager.dismissNewExercise()
                            withAnimation {
                                data.addExercise(categoryID: category.id, from: newExerciseData)
                            }
                        }.disabled(!stateManager.editExerciseChangesMade || stateManager.editExerciseNameEmpty))
                        .navigationTitle("New Exercise")
                }
                .environmentObject(data)
                .environmentObject(stateManager)
            }
        }
    }
    
    private func binding(for exercise: Exercise) -> Binding<Exercise> {
        guard let indices = data.findExerciseIndices(category: category, exercise: exercise) else {
            fatalError("Can't find exercise in category")
        }
        
        return $data.categories[indices.categoryIndex].exercises[indices.exerciseIndex]
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryView(category: .constant(Category.sampleData[0]))
        }
    }
}
