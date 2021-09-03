//
//  PastRecordViewer.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI

struct PastRecordViewer: View {
    @EnvironmentObject var data: MGBData
    let exercise: Exercise
    
    @State private var showDeleteAlert = false
    @State private var logIDsBeingDeleted: [UUID] = []
    var body: some View {
        Section (header: Text("Past records")) {
            ForEach(data.logs.filter{$0.eID == exercise.id}.sorted().reversed()) { log in
                NavigationLink(destination: LogDetailView(log: log, exercise: exercise)) {
                    ExerciseLogCardView(exercise: exercise, log: log)
                        .foregroundColor(Color("Foreground"))
                }
            }
            .onDelete { offsets in
                showDeleteAlert = true
                logIDsBeingDeleted = offsets.map({data.logs.filter{$0.eID == exercise.id}.sorted().reversed()[$0].id})
            }
            .actionSheet(isPresented: $showDeleteAlert) {
                ActionSheet(
                    title: Text("Warning"),
                    message: Text("This log will be deleted permanently and cannot be recovered."),
                    buttons: [
                        .destructive(
                        Text("Delete forever"),
                        action: {
                            withAnimation {
                                data.deleteLog(ids: logIDsBeingDeleted)
                            }
                        }),
                        .cancel()
                ])
            }
            
            if data.logs.filter{$0.eID == exercise.id}.isEmpty {
                Text("No record found").font(.footnote)
            }
        }
    }
    
    private func binding(for log: Log) -> Binding<Log> {
        guard let logIndex = data.logs.firstIndex(where: {$0.id == log.id}) else {
            fatalError("Can't find log")
        }
        
        return $data.logs[logIndex]
    }
}
