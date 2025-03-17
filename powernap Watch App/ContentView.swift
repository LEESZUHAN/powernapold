//
//  ContentView.swift
//  powernap Watch App
//
//  Created by michaellee on 3/17/25.
//  版本2 - 添加版本標記
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "moon.zzz")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Power Nap App")
            Text("版本2")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
