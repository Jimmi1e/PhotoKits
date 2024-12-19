//
//  ContentView.swift
//  PhotoKits
//
//  Created by Jason Young on 2024-12-17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // 相框页面
            NavigationView {
                PhotoProcessorView()
                    .navigationTitle("相框")
            }
            .tabItem {
                Label("相框", systemImage: "photo")
            }

            // 反转胶片页面
            NavigationView {
                FilmInversionView()
                    .navigationTitle("反转胶片")
            }
            .tabItem {
                Label("反转胶片", systemImage: "film")
            }

            // 未来功能扩展
            NavigationView {
                Text("图像风格化")
                    .font(.title)
                    .padding()
            }
            .tabItem {
                Label("AI作画", systemImage: "wand.and.stars")
            }
        }
    }
}









