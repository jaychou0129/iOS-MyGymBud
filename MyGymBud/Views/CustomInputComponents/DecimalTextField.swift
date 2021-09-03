//
//  DecimalTextField.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/14/21.
//

import SwiftUI
import Combine

struct DecimalTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.decimalPad)
            .onReceive(Just(text)) { newValue in
                let filtered = newValue.filter { "0123456789.".contains($0) }
                if filtered != newValue {
                    self.text = filtered
                }
                while let lastIndex = self.text.lastIndex(of: "."), lastIndex != self.text.firstIndex(of: ".") {
                    text.remove(at: lastIndex)
                }
        }
    }
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
}

struct DecimalTextField_Previews: PreviewProvider {
    static var previews: some View {
        DecimalTextField("TEST", text: .constant("test"))
    }
}
