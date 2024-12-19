//
//  PhotoProcessorView.swift
//  PhotoKits
//
//  Created by Jason Young on 2024-12-17.
//

//import SwiftUI
//
//struct PhotoProcessorView: View {
//    @StateObject private var viewModel = PhotoProcessorViewModel()
//    @State private var showImagePicker = false
//    @State private var isProcessing = false // 用于显示加载指示器
//    @State private var showToast = false // 控制 ToastView 显示
//    @State private var toastMessage = "" // ToastView 的消息
//    @State private var toastSuccess = true // ToastView 的成功状态
//
//    var body: some View {
//        ZStack {
//            VStack(spacing: 20) {
//                // 显示图片
//                Group {
//                    if let image = viewModel.processedImage ?? viewModel.selectedImage {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxHeight: 300)
//                    } else {
//                        Text("请先选择一张图片")
//                            .foregroundColor(.gray)
//                    }
//                }
//
//                // 背景颜色选择器与比例选择器
//                Group {
//                    ColorPicker("选择背景/边框颜色", selection: $viewModel.selectedColor)
//                        .padding(.horizontal)
//
//                    Picker("选择输出比例", selection: $viewModel.selectedRatio) {
//                        ForEach(viewModel.ratioOptions, id: \.self) { ratio in
//                            Text(ratio)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    .padding(.horizontal)
//                }
//
//                // 控制按钮
//                Group {
//                    HStack {
//                        Button("挑个图吧") {
//                            showImagePicker = true
//                        }
//                        .buttonStyle(.borderedProminent)
//
//                        Button("主色调框") {
//                            performAction { viewModel.addSolidBackground() }
//                        }
//                        .buttonStyle(.bordered)
//
//                        Button("Blur") {
//                            performAction { viewModel.addBlurredBorder(borderWidth: 150) }
//                        }
//                        .buttonStyle(.bordered)
//                    }
//
//                    HStack {
//                        Button("自定框") {
//                            performAction { viewModel.addBorder() }
//                        }
//                        .buttonStyle(.bordered)
//
//                        Button("保存") {
//                            performSaveAction { viewModel.saveProcessedImage() }
//                        }
//                        .buttonStyle(.borderedProminent)
//                    }
//                }
//
//                // 加载指示器
//                if isProcessing {
//                    ProgressView("Processing...")
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .padding()
//                }
//            }
//            .sheet(isPresented: $showImagePicker) {
//                PhotoPicker(selectedImage: $viewModel.selectedImage)
//            }
//            .padding()
//            .navigationTitle("PhotoKits")
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
//    // 执行动作时显示加载指示器
//    private func performAction(_ action: @escaping () -> Void) {
//        guard viewModel.selectedImage != nil else {
//            showToast(message: "请先选择一张图片", success: false)
//            return
//        }
//
//        isProcessing = true
//        DispatchQueue.global(qos: .userInitiated).async {
//            action()
//            DispatchQueue.main.async {
//                isProcessing = false
//            }
//        }
//    }
//
//    // 保存图片并显示提示框
//    private func performSaveAction(_ action: @escaping () -> Void) {
//        guard viewModel.selectedImage != nil else {
//            showToast(message: "请先选择一张图片", success: false)
//            return
//        }
//
//        isProcessing = true
//        DispatchQueue.global(qos: .userInitiated).async {
//            action()
//            DispatchQueue.main.async {
//                isProcessing = false
//                showToast(message: "保存成功", success: true)
//            }
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

//import SwiftUI
//
//struct PhotoProcessorView: View {
//    @StateObject private var viewModel = PhotoProcessorViewModel()
//    @State private var showImagePicker = false
//    @State private var isProcessing = false
//    @State private var showToast = false
//    @State private var toastMessage = ""
//    @State private var toastSuccess = true
//
//    // 四个页面独立的处理结果
//    @State private var blurResult: UIImage?
//    @State private var solidBorderResult: UIImage?
//    @State private var customBorderResult: UIImage?
//
//    var body: some View {
//        ZStack {
//            TabView {
//                uploadImagePage
//                    .tag(0)
//
//                blurBackgroundPage
//                    .tag(1)
//
//                solidColorBorderPage
//                    .tag(2)
//
//                customBorderPage
//                    .tag(3)
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//            .edgesIgnoringSafeArea(.bottom)
//
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
//        .sheet(isPresented: $showImagePicker) {
//            PhotoPicker(selectedImage: $viewModel.selectedImage)
//        }
//        .navigationTitle("PhotoKits")
//        .padding()
//    }
//
//    // MARK: - 页面定义
//
//    // 0. 上传图片页面
//    private var uploadImagePage: some View {
//        VStack(spacing: 20) {
//            if let image = viewModel.selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: 300)
//            } else {
//                Text("请选择一张图片")
//                    .foregroundColor(.gray)
//            }
//
//            Button("选择图片") {
//                showImagePicker = true
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//
//    // 1. 模糊背景页面
//    private var blurBackgroundPage: some View {
//        VStack(spacing: 20) {
//            if let image = blurResult ?? viewModel.selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: 300)
//            } else {
//                Text("请先选择一张图片")
//                    .foregroundColor(.gray)
//            }
//
//            Text("为图片添加模糊背景")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//
//            HStack {
//                Button("处理") {
//                    guard viewModel.selectedImage != nil else {
//                        showToast(message: "请先选择一张图片", success: false)
//                        return
//                    }
//                    performAction {
//                        viewModel.addBlurredBorder(borderWidth: 150)
//                        blurResult = viewModel.processedImage
//                    }
//                }
//
//                Button("保存图片") {
//                    guard let resultImage = blurResult else {
//                        showToast(message: "无可保存的图片", success: false)
//                        return
//                    }
//                    performSaveAction {
//                        viewModel.processedImage = resultImage
//                        viewModel.saveProcessedImage()
//                    }
//                }
//            }
//            .buttonStyle(.borderedProminent)
//
//            if isProcessing {
//                ProgressView("处理中...")
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .padding()
//            }
//        }
//        .padding()
//    }
//
//    // 2. 主色调边框页面
//    private var solidColorBorderPage: some View {
//        VStack(spacing: 20) {
//            if let image = solidBorderResult ?? viewModel.selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: 300)
//            } else {
//                Text("请先选择一张图片")
//                    .foregroundColor(.gray)
//            }
//
//            Text("根据主色调生成图片边框")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//
//            HStack {
//                Button("处理") {
//                    guard viewModel.selectedImage != nil else {
//                        showToast(message: "请先选择一张图片", success: false)
//                        return
//                    }
//                    performAction {
//                        viewModel.addSolidBackground()
//                        solidBorderResult = viewModel.processedImage
//                    }
//                }
//
//                Button("保存图片") {
//                    guard let resultImage = solidBorderResult else {
//                        showToast(message: "无可保存的图片", success: false)
//                        return
//                    }
//                    performSaveAction {
//                        viewModel.processedImage = resultImage
//                        viewModel.saveProcessedImage()
//                    }
//                }
//            }
//            .buttonStyle(.borderedProminent)
//
//            if isProcessing {
//                ProgressView("处理中...")
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .padding()
//            }
//        }
//        .padding()
//    }
//
//    // 3. 自定义边框页面
//    private var customBorderPage: some View {
//        VStack(spacing: 20) {
//            if let image = customBorderResult ?? viewModel.selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: 300)
//            } else {
//                Text("请先选择一张图片")
//                    .foregroundColor(.gray)
//            }
//
//            Text("自定义图片边框，使用您喜欢的颜色")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//
//            ColorPicker("选择边框颜色", selection: $viewModel.selectedColor)
//                .padding()
//                .onChange(of: viewModel.selectedColor) { _ in
//                    guard viewModel.selectedImage != nil else {
//                        showToast(message: "请先选择一张图片", success: false)
//                        return
//                    }
//
//                    // 实时重新处理
//                    isProcessing = true
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        viewModel.addBorder()
//                        let result = viewModel.processedImage
//                        DispatchQueue.main.async {
//                            customBorderResult = result
//                            isProcessing = false
//                        }
//                    }
//                }
//
//            HStack {
//                Button("处理") {
//                    guard viewModel.selectedImage != nil else {
//                        showToast(message: "请先选择一张图片", success: false)
//                        return
//                    }
//                    performAction {
//                        viewModel.addBorder()
//                        customBorderResult = viewModel.processedImage
//                    }
//                }
//
//                Button("保存图片") {
//                    guard let resultImage = customBorderResult else {
//                        showToast(message: "无可保存的图片", success: false)
//                        return
//                    }
//                    performSaveAction {
//                        viewModel.processedImage = resultImage
//                        viewModel.saveProcessedImage()
//                    }
//                }
//            }
//            .buttonStyle(.borderedProminent)
//
//            if isProcessing {
//                ProgressView("处理中...")
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .padding()
//            }
//        }
//        .padding()
//    }
//
//    // MARK: - 动作与提示框处理
//
//    private func performAction(_ action: @escaping () -> Void) {
//        isProcessing = true
//        DispatchQueue.global(qos: .userInitiated).async {
//            action()
//            DispatchQueue.main.async {
//                isProcessing = false
//            }
//        }
//    }
//
//    private func performSaveAction(_ action: @escaping () -> Void) {
//        isProcessing = true
//        DispatchQueue.global(qos: .userInitiated).async {
//            action()
//            DispatchQueue.main.async {
//                isProcessing = false
//                showToast(message: "保存成功", success: true)
//            }
//        }
//    }
//
//    private func showToast(message: String, success: Bool) {
//        toastMessage = message
//        toastSuccess = success
//        withAnimation {
//            showToast = true
//        }
//    }
//}


import SwiftUI

struct PhotoProcessorView: View {
    @StateObject private var viewModel = PhotoProcessorViewModel()
    @State private var showImagePicker = false
    @State private var isProcessing = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastSuccess = true

    // 独立的状态变量
    @State private var blurResult: UIImage?
    @State private var solidBorderResult: UIImage?
    @State private var customBorderResult: UIImage?

    var body: some View {
        ZStack {
            TabView {
                uploadImagePage.tag(0)

                processingPage(
                    title: "Blur",
                    description: "为图片添加模糊背景",
                    processedImage: $blurResult,
                    action: { viewModel.addBlurredBorder(borderWidth: 150) }
                ).tag(1)

                processingPage(
                    title: "主色调边框",
                    description: "根据主色调生成图片边框",
                    processedImage: $solidBorderResult,
                    action: { viewModel.addSolidBackground() }
                ).tag(2)

                customBorderPage.tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .edgesIgnoringSafeArea(.bottom)

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
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(selectedImage: $viewModel.selectedImage)
        }
        .navigationTitle("PhotoKits")
        .padding()
    }

    // 上传图片页面
    private var uploadImagePage: some View {
        VStack(spacing: 20) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else {
                Text("请选择一张图片")
                    .foregroundColor(.gray)
            }

            Button("选择图片并向右滑动") {
                showImagePicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // 通用处理页面
    private func processingPage(title: String, description: String, processedImage: Binding<UIImage?>, action: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            if let image = processedImage.wrappedValue {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .overlay(ProgressView("处理中..."))
            } else {
                Text("请先选择一张图片")
                    .foregroundColor(.gray)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Button("处理") {
                    guard viewModel.selectedImage != nil else {
                        showToast(message: "请先选择一张图片", success: false)
                        return
                    }
                    performAction {
                        // 点击处理时清空当前结果
                        processedImage.wrappedValue = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 强制刷新 UI
                            action()
                            processedImage.wrappedValue = viewModel.processedImage
                        }
                    }
                }

                Button("保存图片") {
                    guard let resultImage = processedImage.wrappedValue else {
                        showToast(message: "无可保存的图片", success: false)
                        return
                    }
                    performSaveAction {
                        viewModel.processedImage = resultImage
                        viewModel.saveProcessedImage()
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if isProcessing {
                ProgressView("处理中...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .padding()
    }

    // 自定义边框页面
    private var customBorderPage: some View {
        VStack(spacing: 20) {
            if let image = customBorderResult ?? viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            } else {
                Text("请先选择一张图片")
                    .foregroundColor(.gray)
            }

            Text("自定义图片边框，使用您喜欢的颜色")
                .font(.subheadline)
                .foregroundColor(.gray)

            ColorPicker("选择边框颜色", selection: $viewModel.selectedColor)
                .padding()
                .onChange(of: viewModel.selectedColor) { _ in
                    guard viewModel.selectedImage != nil else {
                        showToast(message: "请先选择一张图片", success: false)
                        return
                    }
                    isProcessing = true
                    customBorderResult = nil // 清空当前结果
                    DispatchQueue.global(qos: .userInitiated).async {
                        viewModel.addBorder()
                        DispatchQueue.main.async {
                            customBorderResult = viewModel.processedImage
                            isProcessing = false
                        }
                    }
                }

            HStack {
                Button("处理") {
                    guard viewModel.selectedImage != nil else {
                        showToast(message: "请先选择一张图片", success: false)
                        return
                    }
                    performAction {
                        customBorderResult = nil // 清空当前结果
                        viewModel.addBorder()
                        customBorderResult = viewModel.processedImage
                    }
                }

                Button("保存图片") {
                    guard let resultImage = customBorderResult else {
                        showToast(message: "无可保存的图片", success: false)
                        return
                    }
                    performSaveAction {
                        viewModel.processedImage = resultImage
                        viewModel.saveProcessedImage()
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if isProcessing {
                ProgressView("处理中...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .padding()
    }

    // 执行动作
    private func performAction(_ action: @escaping () -> Void) {
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            action()
            DispatchQueue.main.async {
                isProcessing = false
            }
        }
    }

    // 保存图片动作
    private func performSaveAction(_ action: @escaping () -> Void) {
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            action()
            DispatchQueue.main.async {
                isProcessing = false
                showToast(message: "保存成功", success: true)
            }
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

















