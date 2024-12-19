//
//  FilmInversionView.swift
//  PhotoKits
//
//  Created by Jason Young on 2024-12-18.
//

//import SwiftUI
//
//struct FilmInversionView: View {
//    @StateObject private var viewModel = FilmInversionViewModel()
//    @State private var showImagePicker = false
//    @State private var imageTimestamp = Date() // 添加时间戳
//    @State private var showToast = false // 控制 ToastView 显示
//    @State private var toastMessage = "" // ToastView 的消息
//    @State private var toastSuccess = true // ToastView 的成功状态
//
//    var body: some View {
//        ZStack {
//            VStack {
//                // 图片预览
//                if let image = viewModel.invertedImage ?? viewModel.selectedImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                        .id(imageTimestamp) // 绑定时间戳，强制刷新视图
//                        .frame(maxHeight: 300)
//                        .padding()
//                } else {
//                    Text("请选择一张图片")
//                        .foregroundColor(.gray)
//                        .padding()
//                }
//
//                Spacer()
//
//                // 控制按钮
//                HStack {
//                    Button("选择照片") {
//                        showImagePicker = true
//                    }
//                    .buttonStyle(.borderedProminent)
//
//                    Button("反转胶片") {
//                        performAction {
//                            viewModel.invertImage()
//                            showToast(message: "反转成功", success: true)
//                        }
//                    }
//                    .buttonStyle(.bordered)
//                    .disabled(viewModel.selectedImage == nil)
//
//                    Button("保存图片") {
//                        performAction {
//                            viewModel.saveImage()
//                            showToast(message: "保存成功", success: true)
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(viewModel.invertedImage == nil)
//                }
//                .padding()
//            }
//            .sheet(isPresented: $showImagePicker) {
//                PhotoPicker(selectedImage: Binding(
//                    get: { viewModel.selectedImage },
//                    set: { newValue in
//                        viewModel.selectedImage = newValue
//                        imageTimestamp = Date() // 每次选中新图片时更新时间戳
//                    }
//                ))
//            }
//            .padding()
//            .navigationTitle("目前仅支持黑白哦")
//
//            // 提示框
//            if showToast {
//                ToastView(message: toastMessage, success: toastSuccess)
//                    .transition(.opacity)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                            withAnimation {
//                                showToast = false
//                            }
//                        }
//                    }
//            }
//        }
//    }
//
//    // 统一执行操作
//    private func performAction(_ action: @escaping () -> Void) {
//        if viewModel.selectedImage == nil {
//            showToast(message: "请先选择一张图片", success: false)
//            return
//        }
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            action()
//        }
//    }
//
//    // 显示提示框
//    private func showToast(message: String, success: Bool) {
//        toastMessage = message
//        toastSuccess = success
//        withAnimation {
//            showToast = true
//        }
//    }
//}

import SwiftUI

struct FilmInversionView: View {
    @StateObject private var viewModel = FilmInversionViewModel()
    @State private var showImagePicker = false
    @State private var imageTimestamp = Date() // 添加时间戳
    @State private var showToast = false // 控制 ToastView 显示
    @State private var toastMessage = "" // ToastView 的消息
    @State private var toastSuccess = true // ToastView 的成功状态

    var body: some View {
        ZStack {
            VStack {
                // 图片预览
                if let image = viewModel.invertedImage ?? viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .id(imageTimestamp) // 绑定时间戳，强制刷新视图
                        .frame(maxHeight: 300)
                        .padding()
                } else {
                    Text("请选择一张图片")
                        .foregroundColor(.gray)
                        .padding()
                }

                Spacer()

                // 控制按钮
                HStack {
                    Button("选择照片") {
                        showImagePicker = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("反转胶片") {
                        performAction {
                            viewModel.invertImage()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if viewModel.invertedImage != nil {
                                    showToast(message: "反转成功", success: true)
                                } else {
                                    showToast(message: "反转失败", success: false)
                                }
                                imageTimestamp = Date() // 更新时间戳，刷新视图
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.selectedImage == nil)

                    Button("保存图片") {
                        guard viewModel.invertedImage != nil else {
                            showToast(message: "无可保存的图片", success: false)
                            return
                        }
                        performAction {
                            viewModel.saveImage()
                            DispatchQueue.main.async {
                                showToast(message: "保存成功", success: true)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.invertedImage == nil)
                }
                .padding()
            }
            .sheet(isPresented: $showImagePicker) {
                PhotoPicker(selectedImage: Binding(
                    get: { viewModel.selectedImage },
                    set: { newValue in
                        viewModel.selectedImage = newValue
                        imageTimestamp = Date() // 每次选中新图片时更新时间戳
                    }
                ))
            }
            .padding()
            .navigationTitle("目前仅支持黑白哦")

            // 提示框
            if showToast {
                ToastView(message: toastMessage, success: toastSuccess)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
            }
        }
    }

    // 统一执行操作
    private func performAction(_ action: @escaping () -> Void) {
        guard viewModel.selectedImage != nil else {
            showToast(message: "请先选择一张图片", success: false)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            action()
        }
    }

    // 显示提示框
    private func showToast(message: String, success: Bool) {
        toastMessage = message
        toastSuccess = success
        withAnimation {
            showToast = true
        }
    }
}







