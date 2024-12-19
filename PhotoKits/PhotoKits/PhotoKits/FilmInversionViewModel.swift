//
//  FilmInversionViewModel.swift
//  PhotoKits
//
//  Created by Jason Young on 2024-12-18.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class FilmInversionViewModel: NSObject, ObservableObject {
    @Published var selectedImage: UIImage? {
        didSet {
            // 每次选择新图片时清空反转后的图像
            invertedImage = nil
        }
    }
    @Published var invertedImage: UIImage?

    private let context = CIContext()
    private let invertFilter = CIFilter.colorInvert()
    private let colorControlsFilter = CIFilter.colorControls()
    private let exposureAdjustFilter = CIFilter.exposureAdjust()

    // MARK: - 反转图片并自动调整曝光
    func invertImage() {
        guard let selectedImage = selectedImage,
              let ciImage = CIImage(image: selectedImage) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            // 1. 反转颜色
            self.invertFilter.inputImage = ciImage
            guard let invertedCIImage = self.invertFilter.outputImage else {
                print("反转颜色失败")
                return
            }

            // 2. 调整曝光
            self.exposureAdjustFilter.inputImage = invertedCIImage
            self.exposureAdjustFilter.ev = -0.5 // 曝光调整，避免过曝

            guard let exposureAdjustedImage = self.exposureAdjustFilter.outputImage else {
                print("曝光调整失败")
                return
            }

            // 3. 调整亮度和对比度
            self.colorControlsFilter.inputImage = exposureAdjustedImage
            self.colorControlsFilter.brightness = -0.2 // 进一步优化亮度
            self.colorControlsFilter.contrast = 1.4    // 增加对比度
            self.colorControlsFilter.saturation = 1.0  // 保持饱和度

            guard let colorAdjustedCIImage = self.colorControlsFilter.outputImage else {
                print("亮度/对比度调整失败")
                return
            }

            // 4. 转换为 UIImage
            if let cgImage = self.context.createCGImage(colorAdjustedCIImage, from: colorAdjustedCIImage.extent) {
                let finalImage = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.invertedImage = finalImage
                }
            }
        }
    }

    // MARK: - 保存图片到相册
    func saveImage() {
        guard let image = invertedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            print("保存失败：\(error.localizedDescription)")
        } else {
            print("图片已成功保存到相册！")
        }
    }
}





