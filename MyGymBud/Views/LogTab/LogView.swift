//
//  LogView.swift
//  MyGymBud
//
//  Created by Jay Chou on 5/30/21.
//

import SwiftUI

struct LogView: View {
    @EnvironmentObject var data: MGBData
    @EnvironmentObject var stateManager: StateManager
    
    @State var selectedDate: Date = Date()
    @State var showingLog: Log? = nil
    @State var showingJournalEntry: JournalEntry? = nil
    @State var creatingNewJournalEntry = false
    @State var showDeleteAlert = false
    @State var logIDsBeingDeleted: [UUID] = []
    @State var journalIDsBeingDeleted: [UUID] = []
    var body: some View {
        NavigationView {
            VStack {
                DateViewerPickerView(selectedDay: $selectedDate)
                
                List {
                    JournalSection
                    WorkoutSection
                }
                .listStyle(GroupedListStyle())
                .padding(.top, -40)
                .zIndex(-1)
            }
            .actionSheet(isPresented: $showDeleteAlert) {
                ActionSheet(
                    title: Text("Warning"),
                    message: Text("This \(!logIDsBeingDeleted.isEmpty ? "log" : "journal entry") will be deleted permanently and cannot be recovered."),
                    buttons: [
                        .destructive(
                        Text("Delete forever"),
                        action: {
                            withAnimation {
                                if !logIDsBeingDeleted.isEmpty {
                                    data.deleteLog(ids: logIDsBeingDeleted)
                                    logIDsBeingDeleted = []
                                }
                                if !journalIDsBeingDeleted.isEmpty {
                                    data.deleteJournalEntry(ids: journalIDsBeingDeleted)
                                    journalIDsBeingDeleted = []
                                }
                            }
                        }),
                        .cancel()
                ])
            }
            .navigationBarItems(trailing: AddNewMenu)
            .navigationTitle("Exercise Logs")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: data.deleteLogsWithUndefinedExerciseID)
            .fullScreenCover(isPresented: $stateManager.creatingNewLog) {
                NewLogCategorySelector(date: selectedDate)
                    .environmentObject(data)
                    .environmentObject(stateManager)
            }
            .fullScreenCover(isPresented: $creatingNewJournalEntry) {
                JournalEntryDetailView(date: selectedDate)
                    .environmentObject(data)
            }
            .fullScreenCover(item: $showingLog) { log in
                let exercise = data.findExercise(id: log.eID) ?? Exercise()
                NavigationView {
                    LogDetailView(log: log, exercise: exercise)
                        .navigationBarItems(trailing: HStack(spacing: 10) {
//                            NavigationLink(destination: NewLogExerciseView(exercise: binding(for: data.findExercise(id: log.eID)!), date: log.date, editingLog: log)) {
//                                Image(systemName: "timer")
//                            }
                            
                            Button("Done") {
                                showingLog = nil
                            }
                        })
                }.environmentObject(data)
            }
            .fullScreenCover(item: $showingJournalEntry) { entry in
                JournalEntryDetailView(entry: entry)
                    .environmentObject(data)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var JournalSection: some View {
        Section(header: Text("Journal")) {
            ForEach(data.journal.filter{$0.date.isSameDay(selectedDate)}) { entry in
                Button(action: { showingJournalEntry = entry }) {
                    JournalEntryCard(entry: entry, showDate: false)
                        .foregroundColor(.white)
                }
            }
            .onDelete { offsets in
                journalIDsBeingDeleted = offsets.map({data.journal.filter{$0.date.isSameDay(selectedDate)}[$0].id})
                showDeleteAlert = true
            }
            .listRowBackground(Color.accentColor)
        }.isHidden(data.journal.filter{$0.date.isSameDay(selectedDate)}.isEmpty, remove: true)
    }
    
    private var WorkoutSection: some View {
        Section(header: Text("Workout")) {
            ForEach(data.logs.filter{$0.date.isSameDay(selectedDate)}.sorted()) { log in
                if let ex = data.findExercise(id: log.eID),
                   let rowColor = data.findColor(exerciseID: log.eID) {
                    
                    Button(action: { showingLog = log }) {
                        LogCardView(exercise: ex, log: log)
                            .foregroundColor(rowColor.accessibleFontColor)
                    }
                    .listRowBackground(rowColor)
                    
                }
            }
            .onDelete { offsets in
                logIDsBeingDeleted = offsets.map({data.logs.filter{$0.date.isSameDay(selectedDate)}.sorted()[$0].id})
                showDeleteAlert = true
            }
        }.isHidden(data.logs.filter{$0.date.isSameDay(selectedDate)}.isEmpty, remove: true)
    }
    
    private var AddNewMenu: some View {
        Menu {
            Button(action: {
                stateManager.creatingNewLog = true
            }) {
                Label("New Workout", systemImage: "figure.walk")
            }
            
            Button(action: {
                creatingNewJournalEntry = true
            }) {
                Label("New Journal", systemImage: "doc.append")
            }
        } label: {
            Image(systemName: "plus")
                .padding(15)
        }
        .offset(x: 15, y: 0)
        .disabled(selectedDate > Date())
    }
    
    private func binding(for log: Log) -> Binding<Log> {
        guard let logIndex = data.logs.firstIndex(where: {$0.id == log.id}) else {
            fatalError("Can't find log")
        }
        
        return $data.logs[logIndex]
    }
    
    private func binding(for exercise: Exercise) -> Binding<Exercise> {
        guard let indices = data.findExerciseIndices(exercise: exercise) else {
            fatalError("Can't find exercise in category")
        }
        
        return $data.categories[indices.categoryIndex].exercises[indices.exerciseIndex]
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
            .environmentObject(MGBData())
            .environmentObject(StateManager())
            .preferredColorScheme(.dark)
    }
}
