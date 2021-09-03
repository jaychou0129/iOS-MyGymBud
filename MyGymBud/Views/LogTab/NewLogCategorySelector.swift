//
//  NewLogCategorySelector.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/1/21.
//

import SwiftUI

struct NewLogCategorySelector: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    let date: Date
    
    var body: some View {
        NavigationView {
            ScrollView {
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(data.categories.filter{ $0.enabled }) { category in
                        NavigationLink(destination: NewLogExerciseSelector(category: category, date: date)) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(category.color)
                                Text(category.name)
                                    .padding()
                                    .font(.title2)
                                    .foregroundColor(category.color.accessibleFontColor)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .navigationBarTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel", action: stateManager.dismissNewLog))
        }
    }
}

struct NewLogCategorySelector_Previews: PreviewProvider {
    static var previews: some View {
        NewLogCategorySelector(date: Date())
            .environmentObject(MGBData())
            .environmentObject(StateManager())
    }
}
