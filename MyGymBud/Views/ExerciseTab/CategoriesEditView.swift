//
//  CategoriesEditView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/12/21.
//

import SwiftUI

struct CategoriesEditView: View {
    @EnvironmentObject var data: MGBData
    @State var showEditDetailView: Bool = false
    @State var newCategoryName = ""
    @State var callerID: UUID = UUID()
    
    var body: some View {
        VStack {
            List {
                ForEach(data.categories.sorted()) { category in
                    Button(action: {
                        callerID = category.id
                        showEditDetailView = true
                    }) {
                        HStack {
                            if !category.enabled {
                                Image(systemName: "eye.slash")
                                Text(category.name)
                                    .foregroundColor(.gray)
                                
                            } else {
                                Text(category.name)
                            }
                            Spacer()
                            Circle()
                                .fill(category.color)
                                .frame(width: 30, height: 30, alignment: .trailing)
                        }
                    }
                }
                Button (action: {
                    callerID = UUID() // new ID
                    showEditDetailView = true
                }) {
                    Label("New category", systemImage: "plus.circle.fill")
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Edit Categories", displayMode: .inline)
        .sheet(isPresented: $showEditDetailView) {
                CategoriesEditDetailView()
        }

    }
}

struct CategoriesEditView_Previews: PreviewProvider {
    static private var categories = Category.sampleData
    
    static var previews: some View {
        NavigationView {
            CategoriesEditView()
                .environmentObject(MGBData())
        }
    }
}
