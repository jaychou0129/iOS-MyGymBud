//
//  CategoriesEditView.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/7/21.
//

import SwiftUI

struct CategoriesEditView: View {
    @Binding var data: [Category.Data]
    @State private var newCategoryName = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(data, id: \.self) { item in
                    EditorView(container: $data, index: self.data.firstIndex(of: item)!, name: item.name, color: item.color)
                }
                .onDelete { indices in
                    data.remove(atOffsets: indices)
                }
                HStack {
                    TextField("New Category", text: $newCategoryName)
                    Button(action: {
                        withAnimation {
                            data.append(Category.Data(name: newCategoryName, enabled: true, color: .random))
                            newCategoryName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(newCategoryName.isEmpty)
                }
            }
            if (data.hasEmptyNames()) {
                Text("Please enter a category name!")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Edit Categories")

    }
}

struct EditorView : View {
    var container: Binding<[Category.Data]>
    var index: Int
    @State var name: String
    @State var color: Color
    
    var body: some View {
        HStack {
            TextField("Enter name", text: self.$name, onEditingChanged: { edit in
                        self.container.wrappedValue[self.index].name = self.name})
                
            Spacer()
            ColorPicker("", selection: $color)
                .onChange(of: color) { newValue in
                    self.container.wrappedValue[self.index].color = self.color
                }
        }
    }
}

struct CategoriesEditView_Previews: PreviewProvider {
    static private var categories = Category.sampleData
    static private var categoriesData: [Category.Data] {
        var temp:[Category.Data] = []
        for category in categories {
            temp.append(category.data)
        }
        return temp
    }
    
    static var previews: some View {
        NavigationView {
            CategoriesEditView(data: .constant(categoriesData))
        }
    }
}
