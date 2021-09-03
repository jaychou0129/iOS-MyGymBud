//
//  ListRowTextView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI

struct ListRowTextView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(Color("Foreground"))
            Spacer()
            Text(value)
        }
    }
}

struct ListRowTextView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowTextView(title: "Hello", value: "World")
    }
}
