//
//  ProgressView.swift
//  MyGymBud
//
//  Created by Jay Chou on 8/1/21.
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager

    @State private var showingJournalEntry: JournalEntry? = nil
    @State private var journalIDsBeingDeleted: [UUID] = []
    @State private var showDeleteAlert = false
    @State private var graphViewMode: ProgressGrapher.ViewModeKey = .BodyWeight
    
    var body: some View {
        NavigationView {
            List {
                ProgressGrapher(viewMode: graphViewMode)
                Section(header: Text("Journal Entries")) {
                    ForEach(data.journal.sorted().reversed()) { entry in
                        Button(action: { showingJournalEntry = entry }) {
                            JournalEntryCard(entry: entry, showDate: true)
                                .foregroundColor(.white)
                        }
                    }
                    .onDelete { offsets in
                        journalIDsBeingDeleted = offsets.map({data.journal.sorted().reversed()[$0].id})
                        showDeleteAlert = true
                    }
                    
                    if data.journal.isEmpty {
                        Text("No record found").font(.footnote)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Journal Progress")
            .navigationBarItems(trailing: NavBarButtons)
            .actionSheet(isPresented: $showDeleteAlert) {
                ActionSheet(
                    title: Text("Warning"),
                    message: Text("This journal entry will be deleted permanently and cannot be recovered."),
                    buttons: [
                        .destructive(
                        Text("Delete forever"),
                        action: {
                            withAnimation {
                                data.deleteJournalEntry(ids: journalIDsBeingDeleted)
                                journalIDsBeingDeleted = []
                            }
                        }),
                        .cancel()
                ])
            }
            .fullScreenCover(item: $showingJournalEntry) { entry in
                JournalEntryDetailView(entry: entry)
                    .environmentObject(data)
            }
        }
        
    }
    
    private var NavBarButtons: some View {
        Menu {
            ForEach(ProgressGrapher.ViewModeKey.allCases, id: \.self) { option in
                Button(action: {
                    graphViewMode = option
                }) {
                    Text(option.inString).fontWeight(graphViewMode == option ? .bold : .none)
                    if (graphViewMode == option) {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            Image(systemName: "text.magnifyingglass")
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
