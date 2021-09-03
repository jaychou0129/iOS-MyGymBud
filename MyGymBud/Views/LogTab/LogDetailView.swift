//
//  LogDetailView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/12/21.
//

import SwiftUI

struct LogDetailView: View {
    @EnvironmentObject var data: MGBData
    @Environment(\.presentationMode) var presentationMode

    let log: Log
    let exercise: Exercise
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("INFO")) {
                    ListRowTextView(title: "Exercise", value: exercise.name)
                    ListRowTextView(title: "Date", value: log.date.disp(data.appConfig.dateDisplayMode))
                    ListRowTextView(title: "Notes", value: log.notes)
                    
                }
                
                Section (header: Text("Logs")) {
                    switch exercise.mode {
                    case .Weight:
                        ForEach(log.weightLogs.indices, id: \.self) { logIndex in
                            let w_log = log.weightLogs[logIndex]
                            HStack (alignment: .top) {
                                Text(w_log.weight.disp()).bold().padding(.trailing)
                                VStack {
                                    ForEach (w_log.reps.indices, id: \.self) { repIndex in
                                        let rep = w_log.reps[repIndex]
                                        
                                        HStack {
                                            Text(rep.disp())
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    case .Timed:
                        ForEach(log.timedLogs.indices, id: \.self) { logIndex in
                            let t_log = log.timedLogs[logIndex]
                            HStack {
                                Text(t_log.time.dispText()).bold()
                                Text(" × \(t_log.sets)")
                                Spacer()
                            }
                        }
                    case .Routine:
                        HStack {
                            Text("Total reps:").bold()
                            Text("\(log.routineLogs)")
                            
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle("Workout Log")
    }
}

struct LogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LogDetailView(log: Log(), exercise: Category.sampleData[0].exercises[0])
    }
}
