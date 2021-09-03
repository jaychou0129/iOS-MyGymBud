//
//  ProgressArc.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/27/21.
//

import SwiftUI

struct ProgressArc: Shape {
    let progress: Int
    let total: Int
    
    private var endAngle: Angle {
        Angle(degrees: 360.0 * Double(progress) / Double(total))
    }

    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.origin.x + rect.size.width / 2.0,
                             y: rect.origin.y + rect.size.height / 2.0)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 0), endAngle: endAngle, clockwise: false)
        }
    }
}
