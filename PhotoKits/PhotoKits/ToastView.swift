//
//  ToastView.swift
//  PhotoKits
//
//  Created by Jason Young on 2024-12-18.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var success: Bool

    var body: some View {
        HStack {
            Image(systemName: success ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(success ? .green : .red)
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.8)))
        .padding(.horizontal, 40)
    }
}

