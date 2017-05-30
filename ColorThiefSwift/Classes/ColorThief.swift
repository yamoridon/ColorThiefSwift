//
//  ColorThief.swift
//  ColorThiefSwift
//
//  Created by Kazuki Ohara on 2017/02/11.
//  Copyright © 2017 Kazuki Ohara. All rights reserved.
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

import UIKit

public class ColorThief {

    public static let DefaultQuality = 10
    public static let DefaultIgnoreWhite = true

    /// Use the median cut algorithm to cluster similar colors and return the
    /// base color from the largest cluster.
    ///
    /// - Parameters:
    ///   - sourceImage: the source image
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster a color will be returned but the greater the
    ///              likelihood that it will not be the visually most dominant
    ///              color.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the dominant color
    public static func getColorFromImage(sourceImage: UIImage, quality: Int = DefaultQuality, ignoreWhite: Bool = DefaultIgnoreWhite) -> MMCQ.Color? {
        guard let palette = getPaletteFromImage(sourceImage, colorCount: 5, quality: quality, ignoreWhite: ignoreWhite) else {
            return nil
        }
        let dominantColor = palette[0]
        return dominantColor
    }

    /// Use the median cut algorithm to cluster similar colors.
    ///
    /// - Parameters:
    ///   - sourceImage: the source image
    ///   - colorCount: the size of the palette; the number of colors returned
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster the palette generation but the greater the
    ///              likelihood that colors will be missed.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the palette
    public static func getPaletteFromImage(sourceImage: UIImage, colorCount: Int, quality: Int = DefaultQuality, ignoreWhite: Bool = DefaultIgnoreWhite) -> [MMCQ.Color]? {
        guard let colorMap = getColorMapFromImage(sourceImage, colorCount: colorCount, quality: quality, ignoreWhite: ignoreWhite) else {
            return nil
        }
        return colorMap.palette()
    }

    /// Use the median cut algorithm to cluster similar colors.
    ///
    /// - Parameters:
    ///   - sourceImage: the source image
    ///   - colorCount: the size of the palette; the number of colors returned
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster the palette generation but the greater the
    ///              likelihood that colors will be missed.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the color map
    public static func getColorMapFromImage(sourceImage: UIImage, colorCount: Int, quality: Int = DefaultQuality, ignoreWhite: Bool = DefaultIgnoreWhite) -> MMCQ.ColorMap? {
        guard let pixels = getBytesFromImage(sourceImage) else {
            return nil
        }
        let colorMap = MMCQ.quantizePixels(pixels, quality: quality, ignoreWhite: ignoreWhite, maxColors: colorCount)
        return colorMap
    }

    static func getBytesFromImage(sourceImage: UIImage) -> [UInt8]? {
        guard let cgImage = sourceImage.CGImage else {
            return nil
        }
        if isCompatibleImage(cgImage) {
            return getBytesFromCompatibleImage(cgImage)
        } else {
            return getBytesFromIncompatibleImage(cgImage)
        }
    }

    private static func isCompatibleImage(cgImage: CGImage) -> Bool {
        guard let colorSpace = CGImageGetColorSpace(cgImage) else {
            return false
        }
        if CGColorSpaceGetModel(colorSpace) != .RGB {
            return false
        }
        let bitmapInfo = CGImageGetBitmapInfo(cgImage).rawValue
        let alpha = bitmapInfo & CGBitmapInfo.AlphaInfoMask.rawValue
        let alphaRequirement = (alpha == CGImageAlphaInfo.NoneSkipFirst.rawValue || alpha == CGImageAlphaInfo.First.rawValue)
        let byteOrder = bitmapInfo & CGBitmapInfo.ByteOrderMask.rawValue
        let byteOrderRequirement = (byteOrder == CGBitmapInfo.ByteOrder32Little.rawValue)
        if !(alphaRequirement && byteOrderRequirement) {
            return false
        }
        if CGImageGetBitsPerComponent(cgImage) != 8 {
            return false
        }
        if CGImageGetBitsPerPixel(cgImage) != 32 {
            return false
        }
        if CGImageGetBytesPerRow(cgImage) != CGImageGetWidth(cgImage) * 4 {
            return false
        }
        return true
    }

    private static func getBytesFromCompatibleImage(cgImage: CGImage) -> [UInt8]? {
        guard let dataProvider = CGImageGetDataProvider(cgImage) else {
            return nil
        }
        guard let data = CGDataProviderCopyData(dataProvider) else {
            return nil
        }
        let length = CFDataGetLength(data)
        var rawData = [UInt8](count: length, repeatedValue: 0)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        return rawData
    }

    private static func getBytesFromIncompatibleImage(cgImage: CGImage) -> [UInt8]? {
        let width = CGImageGetWidth(cgImage)
        let height = CGImageGetHeight(cgImage)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.NoneSkipFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
        var rawData = [UInt8](count: width * height * bytesPerPixel, repeatedValue: 0)
        guard let context = CGBitmapContextCreate(&rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else {
            return nil
        }
        CGContextDrawImage(context, CGRect(x: 0, y: 0, width: width, height: height), cgImage)
        return rawData
    }
}
