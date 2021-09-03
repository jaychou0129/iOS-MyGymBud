//
//  ExercisesView.swift
//  MyGymBud
//
//  Created by Jay Chou on 5/30/21.
//

import SwiftUI

struct CategoriesView: View {
    @Binding var categories: [Category]
    @State private var categoriesData: [Category.Data] = []
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            List {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryView(category: binding(for: category))) {
                        HStack {
                            Text(category.name)
                            Spacer()
                            Circle()
                                .fill(category.color)
                                .frame(width: 30, height: 30, alignment: .trailing)
                        }

                    }

                }
            }
            NavigationLink(destination:
                           CategoriesEditView(data: $categoriesData)
                                .navigationBarItems(leading: Button("Cancel") {
                                    self.isEditing = false
                                }, trailing: Button("Done", action: {
                                    self.isEditing = false
                                    categories = rebuild(from: categoriesData)
                                }).disabled(categoriesData.hasEmptyNames())),
                           isActive: $isEditing) {
                EmptyView()
            }
        }
        .navigationTitle("Exercises")
        .navigationBarItems(trailing: Button("Edit", action: {
            self.isEditing = true
            categoriesData.removeAll()
            for category in categories {
                categoriesData.append(category.data)
            }
        }))
    }
    
    private func binding(for category: Category) -> Binding<Category> {
        guard let catIndex = categories.firstIndex(where: { $0.id == category.id }) else {
            fatalError("Can't find category in array")
        }
        return $categories[catIndex]
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoriesView(categories: .constant(Category.sampleData))
        }
        .preferredColorScheme(.dark)
    }
}
