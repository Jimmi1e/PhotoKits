//
//  PhotoProcessorViewModel.swift
//  PhotoKits
//
//  Created by Jason Young on 2024-12-17.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoProcessorViewModel: NSObject, ObservableObject {
    @Published var selectedImage: UIImage? {
        didSet {
            // 清空处理后的图像
            processedImage = nil
        }
    }
    @Published var processedImage: UIImage?
    @Published var selectedColor: Color = .black
    @Published var selectedRatio: String = "3:2"

    let ratioOptions = ["2:3", "3:2", "16:9", "9:16", "4:3", "3:4", "5:4", "4:5"]
    private let context = CIContext(options: [.useSoftwareRenderer: false])

    // MARK: - 添加模糊背景
    func addBlurredBorder(borderWidth: CGFloat = 50) {
        guard let image = selectedImage else {
            print("No image selected.")
            return
        }

        // 压缩并缩放原始图像
        let resizedImage = image.resizedToMaxDimension(1024)

        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciImage = CIImage(image: resizedImage) else {
                print("Failed to create CIImage from UIImage.")
                return
            }

            // 扩展背景尺寸
            let originalExtent = ciImage.extent
            let extendedExtent = originalExtent.insetBy(dx: -borderWidth, dy: -borderWidth)

            // 创建模糊滤镜
            let filter = CIFilter.gaussianBlur()
            filter.inputImage = ciImage.clampedToExtent() // 防止裁剪边缘
            filter.radius = 30 // 模糊半径

            // 生成模糊图像
            guard let outputImage = filter.outputImage else {
                print("Failed to generate output image from Gaussian Blur filter.")
                return
            }

            // 截取扩展后的模糊区域
            guard let blurredCGImage = self.context.createCGImage(outputImage, from: extendedExtent) else {
                print("Failed to create blurred CGImage.")
                return
            }

            let blurredImage = UIImage(cgImage: blurredCGImage)

            // 合成模糊边框和原图
            let combinedImage = UIGraphicsImageRenderer(size: CGSize(width: extendedExtent.width, height: extendedExtent.height)).image { _ in
                // 绘制模糊背景
                blurredImage.draw(in: CGRect(origin: .zero, size: CGSize(width: extendedExtent.width, height: extendedExtent.height)))

                // 绘制原图
                resizedImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: originalExtent.width, height: originalExtent.height))
            }

            // 更新处理后的图像
            DispatchQueue.main.async {
                self.processedImage = combinedImage
            }
        }
    }



    // MARK: - 添加主色调背景框
    func addSolidBackground(withBorderWidth borderWidth: CGFloat = 20) {
        guard let image = selectedImage else { return }

        let resizedImage = image.resizedToMaxDimension(1024)

        DispatchQueue.global(qos: .userInitiated).async {
            let mainColor = self.extractDominantColor(from: resizedImage) ?? UIColor.white
            let newSize = CGSize(
                width: resizedImage.size.width + borderWidth * 2,
                height: resizedImage.size.height + borderWidth * 2
            )

            let solidColorWithBorderImage = UIGraphicsImageRenderer(size: newSize).image { _ in
                mainColor.setFill()
                UIRectFill(CGRect(origin: .zero, size: newSize))
                resizedImage.draw(in: CGRect(
                    x: borderWidth,
                    y: borderWidth,
                    width: resizedImage.size.width,
                    height: resizedImage.size.height
                ))
            }

            DispatchQueue.main.async {
                self.processedImage = solidColorWithBorderImage
            }
        }
    }

    // MARK: - 添加自定义颜色边框
    func addBorder(borderWidth: CGFloat = 20) {
        guard let image = selectedImage else { return }

        let resizedImage = image.resizedToMaxDimension(1024)

        DispatchQueue.global(qos: .userInitiated).async {
            let uiColor = UIColor(self.selectedColor)
            let newSize = CGSize(width: resizedImage.size.width + borderWidth * 2,
                                 height: resizedImage.size.height + borderWidth * 2)
            let borderedImage = UIGraphicsImageRenderer(size: newSize).image { _ in
                uiColor.setFill()
                UIRectFill(CGRect(origin: .zero, size: newSize))
                resizedImage.draw(in: CGRect(x: borderWidth, y: borderWidth,
                                             width: resizedImage.size.width, height: resizedImage.size.height))
            }

            DispatchQueue.main.async {
                self.processedImage = borderedImage
            }
        }
    }

    // MARK: - 提取图像主色调
    private func extractDominantColor(from image: UIImage) -> UIColor? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let extentVector = CIVector(x: ciImage.extent.origin.x, y: ciImage.extent.origin.y,
                                    z: ciImage.extent.size.width, w: ciImage.extent.size.height)

        let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: extentVector
        ])
        guard let outputImage = filter?.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        return UIColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: 1.0)
    }

    // MARK: - 保存图片到相册
    func saveProcessedImage() {
        guard let image = processedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func imageSaveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        if let error = error {
            print("图片保存失败：\(error.localizedDescription)")
        } else {
            print("图片已成功保存到相册。")
        }
    }

    // MARK: - 私有辅助方法
    private func combineImageOnBackground(background: UIImage, image: UIImage) -> UIImage {
        return UIGraphicsImageRenderer(size: background.size).image { _ in
            background.draw(in: CGRect(origin: .zero, size: background.size))
            let origin = CGPoint(x: (background.size.width - image.size.width) / 2,
                                 y: (background.size.height - image.size.height) / 2)
            image.draw(in: CGRect(origin: origin, size: image.size))
        }
    }
}

// MARK: - UIImage 扩展
extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    func resizedToMaxDimension(_ maxDimension: CGFloat) -> UIImage {
        let aspectRatio = self.size.width / self.size.height
        var newSize: CGSize

        if aspectRatio > 1 {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        return self.resize(to: newSize)
    }
}





