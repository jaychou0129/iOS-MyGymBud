//
//  DateViewerPicker.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/19/21.
//

import SwiftUI

struct DateViewerPickerView: View {
    @EnvironmentObject var data: MGBData
    @State private var month = Date()
    @Binding var selectedDay: Date
    var body: some View {
        VStack {
            CalendarView(for: $month, selection: $selectedDay) { date in
                Button (action: { selectedDay = date}) {
                    ZStack {
                        Circle()
                            .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.accentColor)
                            .isHidden(!selectedDay.isSameDay(date))
                        VStack {
                            Spacer()
                            HStack(spacing: 0.4) {
                                let logs = data.logs.filter {$0.date.isSameDay(date)}
                                let colors = colorArray(logs: logs)
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .frame(width: 5, height: 5, alignment: .center)
                                        .foregroundColor(color)
                                }
                            }
                        }
                        Text(DateFormatter.day.string(from: date))
                            .foregroundColor((selectedDay.isSameDay(date)) ? .white : ((Date().isSameDay(date)) ? .accentColor : .none))
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            Divider().padding(.bottom, 5)
        }.background(Color("Background"))
    }
    
    private func findColor(eID: UUID) -> Color {
        for category in data.categories {
            if category.exercises.find(eID: eID) != nil {
                return category.color
            }
        }
        return Color.random
    }
    
    private func colorArray(logs: [Log]) -> [Color] {
        var colors: Set<Color> = []
        for log in logs {
            colors.insert(findColor(eID: log.eID))
        }
        return Array(colors)
    }
}

struct DateViewerPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DateViewerPickerView(selectedDay: .constant(Date()))
            .preferredColorScheme(.dark)
            .environmentObject(MGBData())
    }
}
