//
//  LaunchView.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/26/21.
//

import SwiftUI

struct LaunchView: View {
    @Binding var showLaunchView: Bool
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color("AccentColor")
                .ignoresSafeArea()
            Image("MGB-transparent")
                .resizable()
                .frame(width: 200, height: 200)
        }
        .onReceive(timer) { _ in
            withAnimation {
                showLaunchView = false
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunchView: .constant(true))
    }
}
