//
//  WeightField.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/14/21.
//

import SwiftUI

struct WeightField: View {
    let label: String
    @Binding var weight: Weight?
    
    @State private var valueEntered: String = ""
    @State private var unitSelected: String = ""
    
    init(_ label: String, weight: Binding<Weight?>) {
        self.label = label
        self._weight = weight
    }
    var body: some View {
        HStack {
            DecimalTextField(label, text: $valueEntered)
                .multilineTextAlignment(.trailing)
            if !unitSelected.isEmpty {
                Button(unitSelected) {
                    unitSelected = unitSelected == "kg" ? "lbs" : "kg"
                }
            }

        }
        .onChange(of: valueEntered) { _ in
            if valueEntered.isEmpty {
                weight = nil
                updateUnitDisplay()
            } else {
                if weight == nil {
                    weight = Weight()
                    updateUnitDisplay()
                }
                weight!.update(value: valueEntered)
            }
        }
        .onChange(of: unitSelected) { _ in
            if weight != nil {
                weight!.update(unit: unitSelected)
            }
            updateUnitDisplay()
        }
        .onAppear {
            initialize()
        }
    }
    
    private func initialize() {
        if let weight = weight {
            valueEntered = weight.value.removeTrailingZeros()
            unitSelected = weight.unit.disp()
        } else {
            valueEntered = ""
            unitSelected = ""
        }
    }
    
    private func updateUnitDisplay() {
        if let weight = weight {
            unitSelected = weight.unit.disp()
        } else {
            unitSelected = ""
        }
    }
}

struct WeightField_Previews: PreviewProvider {
    static var previews: some View {
        WeightField("", weight: .constant(Weight(25, Weight.Unit.KG)))
    }
}
