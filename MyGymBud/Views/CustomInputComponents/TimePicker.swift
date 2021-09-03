//
//  TimePicker.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/10/21.
//

import SwiftUI

struct TimePicker: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var time: Time
    let label: String
    let collapsible: Bool
    let maxMinutes: Int
    
    @State private var manualInput = false
    @State private var collapsed = true
    @State private var minEntered = ""
    @State private var secEntered = ""
    
    var body: some View {
        Group {
            Button (action: {collapsed.toggle()}) {
                HStack {
                    Text(label)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                    Text(time.dispTimer())
                        .foregroundColor(collapsed ? (colorScheme == .dark ? Color.white : Color.black) : .accentColor)
                    if !collapsed {
                        Image(systemName: "chevron.down")
                    }
                }
            }.isHidden(!collapsible, remove: true)
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    Toggle("", isOn: $manualInput).labelsHidden()
                }
                if manualInput {
                    HStack(spacing: 10) {
                        PositiveIntegerTextField("", text: $minEntered)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text(":")
                        PositiveIntegerTextField("", text: $secEntered, max: 59, maxDigits: 2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } else {
                    HStack {
                        Picker("Minutes", selection: $minEntered) {
                            ForEach(0...maxMinutes, id: \.self) { min in
                                Text(String(format: "%02d", min)).tag(String(format: "%02d", min))
                            }
                        }
                            .frame(minWidth: 90)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                        Text(":")
                        Picker("Seconds", selection: $secEntered) {
                            ForEach(0...59, id: \.self) { sec in
                                Text(String(format: "%02d", sec)).tag(String(format: "%02d", sec))
                            }
                        }
                            .frame(minWidth: 90)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                    }
                }
            }.isHidden(collapsible && collapsed, remove: true)
        }
        .onAppear {
            minEntered = time.component(.MIN)
            secEntered = time.component(.SEC)
            if (Int(minEntered) ?? 0 > maxMinutes) {
                manualInput = true
            }
        }
        .onChange(of: minEntered) { _ in
            time.update(timerString: (minEntered + ":" + secEntered))
        }
        .onChange(of: secEntered) { _ in
            time.update(timerString: (minEntered + ":" + secEntered))
        }
        .onChange(of: manualInput) { _ in
            if !manualInput {
                if (Int(minEntered) ?? 0 > maxMinutes) {
                    minEntered = "00"
                }
                minEntered = String(format: "%02d", Int(minEntered) ?? 0)
                secEntered = String(format: "%02d", Int(secEntered) ?? 0)
            }
        }
    }
    
    init (label: String = "Time: ", time: Binding<Time>, collapsible: Bool = true, maxMinutes: Int = 120) {
        self.label = label
        self._time = time
        self.collapsible = collapsible
        self.maxMinutes = maxMinutes
    }
}

struct TimePicker_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                Text("Test")
                TimePicker(label: "Rest time:", time: .constant(Time(minutes: 1)), collapsible: true)
                Text("Test")
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
