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
//  https://github.com/orchely/ColorThiefSwift/blob/master/LICENSE
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
        guard let palette = getPaletteFromImage(sourceImage, colorCount: 5, quality: quality, ignoreWhite: ignoreWhite) else { return nil }
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
        guard let colorMap = getColorMapFromImage(sourceImage, colorCount: colorCount, quality: quality, ignoreWhite: ignoreWhite) else { return nil }
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
        guard let byteArray = getByteArrayFromImage(sourceImage) else { return nil }
        let pixels = getPixelsFromByteArray(byteArray, quality: quality, ignoreWhite: ignoreWhite)
        let colorMap = MMCQ.quantizePixels(pixels, maxColors: colorCount)
        return colorMap
    }

    static func getByteArrayFromImage(sourceImage: UIImage) -> [UInt8]? {
        guard let cgImage = sourceImage.CGImage else { return nil }
        guard let dataProvider = CGImageGetDataProvider(cgImage) else { return nil }
        guard let data = CGDataProviderCopyData(dataProvider) else { return nil }
        let length = CFDataGetLength(data)
        var rawData = [UInt8](count: length, repeatedValue: 0)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        return rawData
    }

    static func getPixelsFromByteArray(byteArray: [UInt8], quality: Int, ignoreWhite: Bool) -> [UInt8] {
        let pixelCount = byteArray.count / 4

        // numRegardedPixels must be rounded up to avoid an
        // out of bound exception if all pixels are good.
        let numRegardedPixels = (pixelCount + quality - 1) / quality
        var numUsedPixels = 0
        var pixels = [UInt8](count: numRegardedPixels * 4, repeatedValue: 0)
        for i in 0.stride(to: pixelCount, by: quality) {
            let r = byteArray[i * 4 + 0]
            let g = byteArray[i * 4 + 1]
            let b = byteArray[i * 4 + 2]
            let a = byteArray[i * 4 + 3]

            // If pixel is mostly opaque and not white
            if a >= 125 && !(ignoreWhite && r > 250 && g > 250 && b > 250) {
                pixels[numUsedPixels * 4 + 0] = r
                pixels[numUsedPixels * 4 + 1] = g
                pixels[numUsedPixels * 4 + 2] = b
                numUsedPixels += 1
            }
        }

        if numUsedPixels == numRegardedPixels {
            return pixels
        } else {
            // Remove unused pixels from the array
            return Array(pixels.prefix(numUsedPixels * 4))
        }
    }

}
