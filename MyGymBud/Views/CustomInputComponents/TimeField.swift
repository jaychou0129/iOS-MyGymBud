//
//  TimeField.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/14/21.
//

import SwiftUI

struct TimeField: View {
    @Binding var time: Time?
    @State private var valueEntered: String = ""
    @State private var unitSelected: String = ""
    
    var body: some View {

        HStack {
            if time == nil {
                EmptyView()
            } else {
                DecimalTextField("", text: $valueEntered)
                    .multilineTextAlignment(.trailing)
                DropDownMenu(selected: $unitSelected, label: "Unit", options: Time.Unit.dispList)
            }
        }
        .onChange(of: valueEntered) { newValue in
            time!.update(value: newValue)
        }
        .onChange(of: unitSelected) { newValue in
            time!.update(unit: newValue)
        }
        .onAppear {
            if time == nil {
                time = Time(2, Time.Unit.MIN)
            }
            valueEntered = time!.value.removeTrailingZeros()
            unitSelected = time!.unit.disp()
        }
    }
}

struct TimeField_Previews: PreviewProvider {
    static var previews: some View {
        TimeField(time: .constant(Time(25, Time.Unit.SEC)))
    }
}
