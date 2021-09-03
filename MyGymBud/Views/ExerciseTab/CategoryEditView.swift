//
//  CategoryEditView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/12/21.
//

import SwiftUI

struct CategoryEditView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @State private var detailData = Category.Data()
    @State private var creating: Bool = false
    @State private var changesMade: Bool = false
    @State private var showDeleteAlert: Bool = false
    var body: some View {
        NavigationView {
            List {
                if detailData.enabled {
                    Section(footer: Text("Tap the scribble button for a random color!")) {
                        ListRowComponentView(title: "Title") {
                            TextField("Enter Title", text: $detailData.name)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            ColorPicker("Color", selection: $detailData.color)
                            Button(action: {
                                detailData.color = Color.random
                            }) {
                                Image(systemName: "scribble.variable")
                            }
                        }
                    }
                }
                if !creating {
                    Section (footer: FooterView) {
                        Button(action: {
                            detailData.enabled.toggle()
                        }) {
                            Text(detailData.enabled ? "Hide category" : "Show category")
                                .foregroundColor(detailData.enabled ? .none : .accentColor)
                        }
                        Button("Delete forever") {
                            showDeleteAlert = true
                        }.foregroundColor(.red)
                    }
                }
            }
            .onChange(of: detailData) { _ in
                changesMade = true
            }
            .actionSheet(isPresented: $showDeleteAlert) {
                ActionSheet(
                    title: Text("Warning"),
                    message: Text("All exercises in this category, along with all of their logs, will be deleted permanently and cannot be recovered."),
                    buttons: [
                        .destructive(
                            Text("Delete forever"),
                            action: deleteCategory
                        ),
                        .cancel()
                    ]
                )
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(leading: Button("Cancel") {
                    stateManager.dismissCategoryEditing()
                }, trailing: Button("Save") {
                    saveCategory()
                }.disabled(detailData.name.isEmpty || !changesMade)
            )
            
        }
        .onAppear(perform: {
            if let category = stateManager.editingCategory,
               let caller = data.findCategory(id: category.id) {
                detailData = caller.data
            } else {
                // new
                detailData = Category.Data()
                creating = true
            }
        })
    }
    
    private func deleteCategory() -> Void {
        if let category = stateManager.editingCategory {
            data.deleteCategory(id: category.id)
        }
        stateManager.dismissCategoryEditing()
    }
    
    private func saveCategory() -> Void {
        if let category = stateManager.editingCategory {
            data.updateCategory(id: category.id, from: detailData)
        }
        stateManager.dismissCategoryEditing()
    }
    
    private var FooterView: some View {
        Text("This category is disabled. Tap \"Show category\" to enable it before editing.")
            .isHidden(detailData.enabled, remove: true)
    }
}

struct CategoriesEditDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryEditView()
            .environmentObject(MGBData())
            .environmentObject(StateManager())
    }
}
