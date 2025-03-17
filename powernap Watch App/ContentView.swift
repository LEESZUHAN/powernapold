//
//  ContentView.swift
//  powernap Watch App
//
//  Created by michaellee on 3/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "moon.zzz")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Power Nap App")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
