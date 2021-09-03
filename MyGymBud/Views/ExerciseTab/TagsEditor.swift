//
//  TagsEditor.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/29/21.
//

import SwiftUI

struct TagsEditor: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var tags: [String]
    let suggestions = ["Dumbbell", "Barbell", "Bodyweight", "EZ Bar", "Kettlebell", "Smith", "Bench", "Unilateral"]
    
    @State private var tagsTextField = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tags"), footer: Text("Tap on a tag to remove it.")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(tags.indices, id: \.self) { index in
                                TagBubble(tagName: tags[index])
                                    .onTapGesture {
                                        tags.remove(at: index)
                                    }
                            }
                        }
                    }
                }
                .padding(.bottom)
                
                Section(header: Text("Add tags")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(suggestions.indices, id: \.self) { index in
                                if !tags.contains(suggestions[index]) {
                                    TagBubble(tagName: suggestions[index])
                                    .onTapGesture {
                                        tags.append(suggestions[index])
                                    }
                                }
                            }
                        }
                    }
                    HStack {
                        TextField("Enter tag", text: $tagsTextField)
                        Button(action: {
                            tags.append(tagsTextField)
                            tagsTextField = ""
                        }) {
                            Image(systemName: "plus")
                        }.disabled(tagsTextField.isEmpty)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: Button("Done") {
                                    presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TagBubble: View {
    
    let tagName: String
    
    var body: some View {
        Text(tagName)
            .padding(3.0)
            .font(.caption)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}

struct TagsEditor_Previews: PreviewProvider {
    static var previews: some View {
        TagsEditor(tags: .constant(["one", "two"]))
    }
}
