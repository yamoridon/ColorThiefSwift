//
//  ColorThief.swift
//  ColorThiefSwift
//
//  Created by Kazuki Ohara on 2017/02/11.
//  Copyright © 2019 Kazuki Ohara. All rights reserved.
//
//  License
//  -------
//  MIT License
//  https://github.com/yamoridon/ColorThiefSwift/blob/master/LICENSE
//
//  Thanks
//  ------
//  Lokesh Dhakar - for the original Color Thief JavaScript version
//  http://lokeshdhakar.com/projects/color-thief/
//  Sven Woltmann - for the fast Java Implementation
//  https://github.com/SvenWoltmann/color-thief-java

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
public typealias PlatformNativeImage = UIImage
public typealias PlatformNativeColor = UIColor
#elseif canImport(AppKit)
public typealias PlatformNativeImage = NSImage
public typealias PlatformNativeColor = NSColor
#endif

public class ColorThief {

    public static let defaultQuality = 10
    public static let defaultIgnoreWhite = true

    /// Use the median cut algorithm to cluster similar colors and return the
    /// base color from the largest cluster.
    ///
    /// - Parameters:
    ///   - image: the source image
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster a color will be returned but the greater the
    ///              likelihood that it will not be the visually most dominant
    ///              color.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the dominant color
    public static func getColor(from image: PlatformNativeImage, quality: Int = defaultQuality, ignoreWhite: Bool = defaultIgnoreWhite) -> MMCQ.Color? {
        guard let palette = getPalette(from: image, colorCount: 5, quality: quality, ignoreWhite: ignoreWhite) else {
            return nil
        }
        let dominantColor = palette[0]
        return dominantColor
    }

    /// Use the median cut algorithm to cluster similar colors.
    ///
    /// - Parameters:
    ///   - image: the source image
    ///   - colorCount: the size of the palette; the number of colors returned.
    ///                 *the actual size of array becomes smaller than this.
    ///                 this is intended to align with the original Java version.*
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster the palette generation but the greater the
    ///              likelihood that colors will be missed.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the palette
    public static func getPalette(from image: PlatformNativeImage, colorCount: Int, quality: Int = defaultQuality, ignoreWhite: Bool = defaultIgnoreWhite) -> [MMCQ.Color]? {
        guard let colorMap = getColorMap(from: image, colorCount: colorCount, quality: quality, ignoreWhite: ignoreWhite) else {
            return nil
        }
        return colorMap.makePalette()
    }

    /// Use the median cut algorithm to cluster similar colors.
    ///
    /// - Parameters:
    ///   - image: the source image
    ///   - colorCount: the size of the palette; the number of colors returned.
    ///                 *the actual size of array becomes smaller than this.
    ///                 this is intended to align with the original Java version.*
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster the palette generation but the greater the
    ///              likelihood that colors will be missed.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the color map
    public static func getColorMap(from image: PlatformNativeImage, colorCount: Int, quality: Int = defaultQuality, ignoreWhite: Bool = defaultIgnoreWhite) -> MMCQ.ColorMap? {
        guard let pixels = makeBytes(from: image) else {
            return nil
        }
        let colorMap = MMCQ.quantize(pixels, quality: quality, ignoreWhite: ignoreWhite, maxColors: colorCount)
        return colorMap
    }

    static func makeBytes(from image: PlatformNativeImage) -> [UInt8]? {
        #if canImport(UIKit)
        guard let cgImage = image.cgImage else {
            return nil
        }
        #elseif canImport(AppKit)
        guard let rawCGImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let colorSpace = NSColorSpace.sRGB
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil,
                                width: rawCGImage.width,
                                height: rawCGImage.height,
                                bitsPerComponent: rawCGImage.bitsPerComponent,
                                bytesPerRow: rawCGImage.bytesPerRow,
                                space: colorSpace.cgColorSpace!,
                                bitmapInfo: bitmapInfo.rawValue)
        context?.draw(rawCGImage, in: CGRect(x: 0, y: 0, width: CGFloat(rawCGImage.width), height: CGFloat(rawCGImage.height)))
        guard let cgImage = context?.makeImage() else {
            return nil
        }
        #endif
        if isCompatibleImage(cgImage) {
            return makeBytesFromCompatibleImage(cgImage)
        } else {
            return makeBytesFromIncompatibleImage(cgImage)
        }
    }

    static func isCompatibleImage(_ cgImage: CGImage) -> Bool {
        guard let colorSpace = cgImage.colorSpace else {
            return false
        }
        if colorSpace.model != .rgb {
            return false
        }
        let bitmapInfo = cgImage.bitmapInfo
        let alpha = bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let alphaRequirement = (alpha == CGImageAlphaInfo.noneSkipLast.rawValue || alpha == CGImageAlphaInfo.last.rawValue)
        let byteOrder = bitmapInfo.rawValue & CGBitmapInfo.byteOrderMask.rawValue
        let byteOrderRequirement = (byteOrder == CGBitmapInfo.byteOrder32Little.rawValue)
        if !(alphaRequirement && byteOrderRequirement) {
            return false
        }
        if cgImage.bitsPerComponent != 8 {
            return false
        }
        if cgImage.bitsPerPixel != 32 {
            return false
        }
        if cgImage.bytesPerRow != cgImage.width * 4 {
            return false
        }
        return true
    }

    static func makeBytesFromCompatibleImage(_ image: CGImage) -> [UInt8]? {
        guard let dataProvider = image.dataProvider else {
            return nil
        }
        guard let data = dataProvider.data else {
            return nil
        }
        let length = CFDataGetLength(data)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        return rawData
    }

    static func makeBytesFromIncompatibleImage(_ image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
                return nil
        }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return rawData
    }

}
