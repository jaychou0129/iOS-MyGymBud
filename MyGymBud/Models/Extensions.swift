//
//  Extensions.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/7/21.
//

import SwiftUI


//private struct DeletePairKey: EnvironmentKey {
//    static let defaultValue: Binding<(UUID, UUID)?> = .constant(nil)
//}
//
//extension EnvironmentValues {
//    var deleteExercise: Binding<(UUID, UUID)?> {
//        get { self[DeletePairKey.self] }
//        set { self[DeletePairKey.self] = newValue }
//    }
//}

extension View {
    
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

extension Date {
    func isSameDay(_ date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    
    func disp(_ mode: AppConfiguration.DateDisplayMode) -> String {
        let dateformat = DateFormatter()
        switch mode {
        case .numeric:
            dateformat.dateFormat = "M/d/yyyy"
        case .textLong:
            dateformat.dateStyle = .long
        case .textMedium:
            dateformat.dateStyle = .medium
        case .textShort:
            dateformat.dateStyle = .short
        }
        
        return dateformat.string(from: self)
    }
    
    func dispTime() -> String {
        let dateformat = DateFormatter()
        dateformat.timeStyle = .short
        return dateformat.string(from: self)
    }
    
    static func createDate(onDay: Date, atTime: Date) -> Date {
        // returns a Date object at 'time' on 'day'
        var components = Calendar.current.dateComponents([.year, .month, .day], from: onDay)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: atTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        return Calendar.current.date(from: components)!
    }
}

extension Double {
    func removeTrailingZeros() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
extension Int {
    func toString() -> String {
        return String(self)
    }
}

extension Dictionary where Value: Equatable {
    func keyOf(_ val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func == <T:Equatable> (tuple1:(T,T),tuple2:(T,T)) -> Bool
{
   return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}
