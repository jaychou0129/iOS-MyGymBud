//
//  ListRowComponentView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI

struct ListRowComponentView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {

        HStack {
            Text(title).foregroundColor(Color("Foreground"))
            Spacer()
            content
        }
    }
}
