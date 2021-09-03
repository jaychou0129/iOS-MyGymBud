//
//  PositiveIntegerTextField.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/14/21.
//

import SwiftUI
import Combine

struct PositiveIntegerTextField: View {
    var placeholder: String
    @Binding var text: String
    let max: Int
    let maxDigits: Int
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .onReceive(Just(text)) { newValue in
                var filtered = newValue.filter { "0123456789".contains($0) }
                
                while filtered.count > maxDigits {
                    filtered.removeLast()
                }
                
                if (Int(filtered) ?? 0 > max) {
                    filtered = String(max)
                }
                
                if filtered != newValue {
                    self.text = filtered
                }
        }
    }
    
    init(_ placeholder: String, text: Binding<String>, max: Int = 1000000, maxDigits: Int = 10) {
        self.placeholder = placeholder
        self._text = text
        self.max = max
        self.maxDigits = maxDigits
    }
}

struct PositiveIntegerTextField_Previews: PreviewProvider {
    static var previews: some View {
        PositiveIntegerTextField("TEST", text: .constant("test"))
    }
}
