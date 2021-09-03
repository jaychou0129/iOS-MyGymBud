//
//  ChartTest.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/15/21.
//

import SwiftUI

struct ChartTest: View {
    var body: some View {
        VStack {
            LineView(data: [("ONE", 8),("TWO", 23),("THREE", 54),("FOUR", 43)], title: "Line chart", legend: "Full screen")
                .padding()
                .frame(maxHeight: 300)
            Text("test")
        }
    }
}

struct ChartTest_Previews: PreviewProvider {
    static var previews: some View {
        ChartTest()
            .preferredColorScheme(.dark)
    }
}
