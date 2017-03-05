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

open class ColorThief {

    open static let DefaultQuality = 10
    open static let DefaultIgnoreWhite = true

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
    open static func getColor(from image: UIImage, quality: Int = DefaultQuality, ignoreWhite: Bool = DefaultIgnoreWhite) -> MMCQ.Color? {
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
    open static func getPalette(from image: UIImage, colorCount: Int, quality: Int = DefaultQuality, ignoreWhite: Bool = DefaultIgnoreWhite) -> [MMCQ.Color]? {
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
    open static func getColorMap(from image: UIImage, colorCount: Int, quality: Int = DefaultQuality, ignoreWhite: Bool = DefaultIgnoreWhite) -> MMCQ.ColorMap? {
        guard let pixels = makeByteArray(from: image) else {
            return nil
        }
        let colorMap = MMCQ.quantize(pixels, quality: quality, ignoreWhite: ignoreWhite, maxColors: colorCount)
        return colorMap
    }

    static func makeByteArray(from image: UIImage) -> [UInt8]? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        guard let dataProvider = cgImage.dataProvider else {
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

}
