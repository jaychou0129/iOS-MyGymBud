//
//  WeightRepsPicker.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/11/21.
//

import SwiftUI

struct WeightRepsPicker: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var weight: Weight
    @Binding var reps: Int
    let label: String
    let collapsible: Bool
    let maxWeight: Int
    let maxReps: Int
    
    @State private var manualInput = false
    @State private var collapsed = true
    @State private var weightEntered = ""
    @State private var unitEntered = ""
    @State private var repsEntered = ""
    
    var body: some View {
        Group {
            Button (action: {collapsed.toggle()}) {
                HStack {
                    Text(label)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                    Text("\(weight.disp()) × \(reps)")
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
                        DecimalTextField("", text: $weightEntered)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Picker("", selection: $unitEntered) {
                            ForEach(Weight.Unit.dispList, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                            .frame(minWidth: 70, maxWidth: 80)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                        Text("×")
                        PositiveIntegerTextField("", text: $repsEntered)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                } else {
                    HStack {
                        Picker("Weight", selection: $weightEntered) {
                            ForEach(0...maxWeight, id: \.self) { weight in
                                Text("\(weight)").tag(String(weight))
                            }
                        }
                            .frame(minWidth: 90)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                        
                        Picker("Unit", selection: $unitEntered) {
                            ForEach(Weight.Unit.dispList, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                            .frame(minWidth: 70, maxWidth: 80)
                            .clipped()
                            .pickerStyle(WheelPickerStyle())
                        
                        Text("×")
                        Picker("Reps", selection: $repsEntered) {
                            ForEach(1...maxReps, id: \.self) { reps in
                                Text("\(reps)").tag(String(reps))
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
            weightEntered = weight.value.removeTrailingZeros()
            repsEntered = String(reps)
            unitEntered = weight.unit.disp()
            
            if (floor(weight.value) != weight.value || Int(weight.value) > maxWeight || reps > maxReps) {
                manualInput = true
            }
        }
        .onChange(of: weightEntered) { _ in
            weight.update(value: weightEntered)
        }
        .onChange(of: unitEntered) { _ in
            weight.update(unit: unitEntered)
        }
        .onChange(of: repsEntered) { _ in
            reps = Int(repsEntered) ?? 1
        }
        .onChange(of: manualInput) { _ in
            weightEntered = weight.value.removeTrailingZeros()
            repsEntered = String(reps)
            unitEntered = weight.unit.disp()
            if !manualInput {
                if (Int(weight.value) > maxWeight) {
                    weightEntered = "0"
                }
                if (floor(weight.value) != weight.value) {
                    weightEntered = String(floor(weight.value).removeTrailingZeros())
                }
                if (reps > maxReps || reps < 1) {
                    repsEntered = "1"
                }
            }
        }
    }
    
    init (label: String = "Weight/Reps: ", weight: Binding<Weight>, reps: Binding<Int>, collapsible: Bool = true, maxWeight: Int = 300, maxReps: Int = 40) {
        self.label = label
        self._weight = weight
        self._reps = reps
        self.collapsible = collapsible
        self.maxWeight = maxWeight
        self.maxReps = maxReps
    }
}

struct WeightRepsPicker_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                Text("Test")
                WeightRepsPicker(label: "Default weight/reps:", weight: .constant(Weight(25.0, .KG)), reps: .constant(15), collapsible: true)
                Text("Test")
            }
        }.listStyle(InsetGroupedListStyle())
    }
}
