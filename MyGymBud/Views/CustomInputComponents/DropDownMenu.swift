//
//  DropdownMenu.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/13/21.
//

import SwiftUI

struct DropDownMenu: View {
    @Binding var selected: String
    let label: String
    let options: [String]
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selected = option
                }) {
                    Text(option)
                    if (option == selected) {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        } label: {
            selected.isEmpty ? Text(label) : Text(selected)
            Image(systemName: "chevron.down")
                .font(.caption)
        }
    }
}

struct DropdownMenu_Previews: PreviewProvider {
    static var previews: some View {
        DropDownMenu(selected: .constant(""), label: "Mode", options: ["Weight", "Timed", "Routine"])
    }
}
