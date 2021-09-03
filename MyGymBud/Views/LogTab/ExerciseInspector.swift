//
//  ExerciseInspector.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI

struct ExerciseInspector: View {
    @EnvironmentObject var data: MGBData
    @Environment(\.presentationMode) var presentationMode
    let exercise: Exercise
    
    var body: some View {
        NavigationView {
            List {
                Grapher(exercise: exercise)
                PastRecordViewer(exercise: exercise)
            }
            .listStyle(GroupedListStyle())
            .navigationTitle(exercise.name)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        
    }
}

struct ExerciseInspector_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseInspector(exercise: Category.sampleData[0].exercises[0])
            .environmentObject(MGBData())
    }
}
