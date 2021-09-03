//
//  JournalEntryDetailView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/31/21.
//

import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var data: MGBData
    @State private var entryData = JournalEntry.Data()
    
    var date: Date?
    var entry: JournalEntry?
    
    // new entry
    init(date: Date) {
        self.date = date
    }
    
    // edit entry
    init(entry: JournalEntry) {
        self.entry = entry
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Measurements")) {
                    ListRowComponentView(title: "Body Weight") {
                        WeightField("Optional", weight: $entryData.bodyWeight)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "Body Fat %") {
                        DecimalTextField("Optional", text: $entryData.bodyFatPercentage)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "BMR") {
                        PositiveIntegerTextField("Optional", text: $entryData.bmr)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "BMI") {
                        DecimalTextField("Optional", text: $entryData.bmi)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "Ske. Muscle Mass") {
                        WeightField("Optional", weight: $entryData.skeMuscleMass)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section(header: Text("Diet")) {
                    ListRowComponentView(title: "Total Calories") {
                        PositiveIntegerTextField("Optional", text: $entryData.totalCalories)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "Carbohydrates (g)") {
                        DecimalTextField("Optional", text: $entryData.carbohydrateGrams)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "Proteins (g)") {
                        DecimalTextField("Optional", text: $entryData.proteinGrams)
                            .multilineTextAlignment(.trailing)
                    }
                    ListRowComponentView(title: "Fats (g)") {
                        DecimalTextField("Optional", text: $entryData.fatGrams)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section (header: Text("Notes")) {
                    HStack {
                        TextEditor(text: $entryData.notes)
                        Button(action: {
                            UIApplication.shared.endEditing()
                        }) {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    }
                    
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                if let entry = entry {
                    entryData = entry.data
                } else if let date = date {
                    entryData.date = date
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(entryData.date.disp(data.appConfig.dateDisplayMode))
            .navigationBarItems(leading: CancelButton, trailing: DoneButton)
        }
    }
    
    private var CancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }.isHidden(entry != nil, remove: true)
    }
    private var DoneButton: some View {
        Group {
            // editing
            if let entry = entry {
                Button("Done") {
                    data.updateJournalEntry(entry: entry, from: entryData)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            // adding
            else {
                Button("Save") {
                    data.newJournalEntry(data: entryData)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct NewJournalEntryView_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryDetailView(date: Date())
    }
}
