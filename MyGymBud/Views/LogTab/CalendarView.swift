import SwiftUI

extension DateFormatter {
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
}

fileprivate extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    @Binding var month: Date
    @Binding var selection: Date
    let content: (Date) -> DateView

    init(
        for month: Binding<Date>,
        selection: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self._month = month
        self._selection = selection
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 5) {
            Section(header: header(for: month)) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                    Text (symbol)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                ForEach(days(for: month), id: \.self) { date in
                    if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                        content(date)
                    } else {
                        Text(DateFormatter.day.string(from: date))
                            .foregroundColor(.gray)
                            .onTapGesture {
                                if date < month {
                                    goToPreviousMonth(selectDate: date)
                                } else {
                                    goToNextMonth(selectDate: date)
                                }
                            }
                    }
                }
            }
        }
    }

    private func header(for month: Date) -> some View {
        HStack {
            Text(DateFormatter.monthAndYear.string(from: month))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding()
            Spacer()
            Button(action: goToToday) {
                Text("Today")
            }.padding(.trailing)
            Button(action: goToPreviousMonth) {
                Image(systemName: "chevron.backward")
            }.padding(.trailing)
            Button(action: goToNextMonth) {
                Image(systemName: "chevron.forward")
            }.padding(.trailing)
        }
    }

    private func days(for month: Date) -> [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month),
            let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end-1)
        else { return [] }
        return calendar.generateDates(
            inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    private func goToToday() -> Void {
        if (!Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)) {
            month = Date()
        }
        selection = Date()
    }
    
    private func goToPreviousMonth() -> Void {
        goToMonth(monthAwayFromCurrent: -1)
    }
    private func goToPreviousMonth(selectDate: Date) -> Void {
        goToMonth(monthAwayFromCurrent: -1, selectDate: selectDate)
    }
    
    private func goToNextMonth() -> Void {
        goToMonth(monthAwayFromCurrent: 1)
    }
    private func goToNextMonth(selectDate: Date) -> Void {
        goToMonth(monthAwayFromCurrent: 1, selectDate: selectDate)
    }
    
    private func goToMonth(monthAwayFromCurrent: Int, selectDate: Date? = nil) {
        month = Calendar.current.date(byAdding: .month, value: monthAwayFromCurrent, to: month)!
        
        if let date = selectDate, Calendar.current.isDate(month, equalTo: date, toGranularity: .month) {
            selection = date
        } else {
            if (Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month)) {
                // select today if in current month
                selection = Date()
            } else {
                // select start of month if not in current month
                var components = Calendar.current.dateComponents([.year, .month], from: month)
                components.day = 1
                selection = Calendar.current.date(from: components)!
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    
    
    struct CalendarDemo: View {
        @State private var month = Date()
        @State private var selection = Date()
        var body: some View {
            CalendarView(for: $month, selection: $selection) { date in
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.accentColor)
                    Text(String(Calendar.current.dateComponents([.day], from: date).day!))
                        .foregroundColor(.white)
                }
            }
        }
    }
    static var previews: some View {
        CalendarDemo()
    }
}
