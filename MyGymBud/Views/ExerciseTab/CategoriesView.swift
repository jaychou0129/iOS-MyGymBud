//
//  ExercisesView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/12/21.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(data.categories) { category in
                    if editMode == .active || category.enabled {
                        ZStack {
                            CategoryCard(category: category, editMode: editMode)
                            NavigationLink(destination: CategoryView(category: binding(for: category)), tag: category.id, selection: $stateManager.presentingCategoryID) {
                                EmptyView()
                            }.hidden()
                        }
                    }
                }
                .onMove { data.moveCategory(from: $0, to: $1) }
            }
            .sheet(item: $stateManager.editingCategory) { _ in
                CategoryEditView()
            }
            .navigationTitle("Exercises")
            .navigationBarItems(leading: EditButton(), trailing: AddButton)
            .environment(\.editMode, $editMode)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func binding(for category: Category) -> Binding<Category> {
        guard let index = data.findCategoryIndex(category: category) else {
            fatalError("Can't find category")
        }
        return $data.categories[index]
    }
    
    private var AddButton: some View {
        Button(action: {
            stateManager.editingCategory = Category(name: "", color: .random)
        }) {
            Image(systemName: "plus")
        }.isHidden(editMode != .active, remove: true)
    }
    
    private struct CategoryCard: View {
        @EnvironmentObject var stateManager: StateManager
        let category: Category
        let editMode: EditMode
        
        var body: some View {
            HStack {
                Capsule()
                    .fill(category.color)
                    .frame(width: 4)
                if !category.enabled {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.secondary)
                }
                Text(category.name)
                    .foregroundColor(category.enabled ? .none : .secondary)
                Spacer()
                if editMode == .active {
                    Image(systemName: "pencil")
                    .onTapGesture {
                        stateManager.editingCategory = category
                    }
                } else {
                    Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .preferredColorScheme(.dark)
            .environmentObject(MGBData())
            .environmentObject(StateManager())
    }
}
