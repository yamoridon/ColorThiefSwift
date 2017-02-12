//
//  MMCQ.swift
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

import Foundation

// MMCQ (modified median cut quantization) algorithm from
// the Leptonica library (http://www.leptonica.com/).
public class MMCQ {

    // Use only upper 5 bits of 8 bits
    private static let SignalBits = 5
    private static let RightShift = 8 - SignalBits
    private static let Multiplier = 1 << RightShift
    private static let HistogramSize = 1 << (3 * SignalBits)
    private static let VBoxLength = 1 << SignalBits
    private static let FractionByPopulation = 0.75
    private static let MaxIterations = 1000

    /// Get reduced-space color index for a pixel.
    ///
    /// - Parameters:
    ///   - red: the red value
    ///   - green: the green value
    ///   - blue: the blue value
    /// - Returns: the color index
    static func getColorIndexOfRed(red: Int, green: Int, blue: Int) -> Int {
        return (red << (2 * SignalBits)) + (green << SignalBits) + blue
    }

    public struct Color {
        public var r: UInt8
        public var g: UInt8
        public var b: UInt8

        init(r: UInt8, g: UInt8, b: UInt8) {
            self.r = r
            self.g = g
            self.b = b
        }

        public func toUIColor() -> UIColor {
            return UIColor(red: CGFloat(r) / CGFloat(255), green: CGFloat(g) / CGFloat(255), blue: CGFloat(b) / CGFloat(255), alpha: CGFloat(1))
        }
    }

    enum ColorChannel {
        case r
        case g
        case b
    }

    /// 3D color space box.
    class VBox {

        var rMin: UInt8
        var rMax: UInt8
        var gMin: UInt8
        var gMax: UInt8
        var bMin: UInt8
        var bMax: UInt8

        private let histogram: [Int]

        private var average: Color?
        private var volume: Int?
        private var count: Int?

        init(rMin: UInt8, rMax: UInt8, gMin: UInt8, gMax: UInt8, bMin: UInt8, bMax: UInt8, histogram: [Int]) {
            self.rMin = rMin
            self.rMax = rMax
            self.gMin = gMin
            self.gMax = gMax
            self.bMin = bMin
            self.bMax = bMax
            self.histogram = histogram
        }

        /// Get 3 dimensional volume of the color space
        ///
        /// - Parameter force: force recalculate
        /// - Returns: the volume
        func getVolume(forceRecalculate force: Bool = false) -> Int {
            if volume == nil || force {
                volume = (Int(rMax) - Int(rMin) + 1) * (Int(gMax) - Int(gMin) + 1) * (Int(bMax) - Int(bMin) + 1)
            }
            return volume!
        }

        /// Get total count of histogram samples
        ///
        /// - Parameter force: force recalculate
        /// - Returns: the volume
        func getCount(forceRecalculate force: Bool = false) -> Int {
            if count == nil || force {
                var npix = 0
                for i in Int(rMin) ... Int(rMax) {
                    for j in Int(gMin) ... Int(gMax) {
                        for k in Int(bMin) ... Int(bMax) {
                            let index = MMCQ.getColorIndexOfRed(i, green: j, blue: k)
                            npix += histogram[index]
                        }
                    }
                }
                count = npix
            }

            return count!
        }

        func clone() -> VBox {
            return VBox(rMin: rMin, rMax: rMax, gMin: gMin, gMax: gMax, bMin: bMin, bMax: bMax, histogram: histogram)
        }

        func getAverage(forceRecalculate force: Bool = false) -> Color {
            if average == nil || force {
                var ntot = 0

                var rSum = 0
                var gSum = 0
                var bSum = 0

                for i in Int(rMin) ... Int(rMax) {
                    for j in Int(gMin) ... Int(gMax) {
                        for k in Int(bMin) ... Int(bMax) {
                            let index = MMCQ.getColorIndexOfRed(i, green: j, blue: k)
                            let hval = histogram[index]
                            ntot += hval
                            rSum += Int(Double(hval) * (Double(i) + 0.5) * Double(MMCQ.Multiplier))
                            gSum += Int(Double(hval) * (Double(j) + 0.5) * Double(MMCQ.Multiplier))
                            bSum += Int(Double(hval) * (Double(k) + 0.5) * Double(MMCQ.Multiplier))
                        }
                    }
                }

                if ntot > 0 {
                    let r = UInt8(rSum / ntot)
                    let g = UInt8(gSum / ntot)
                    let b = UInt8(bSum / ntot)
                    average = Color(r: r, g: g, b: b)
                } else {
                    let r = UInt8(MMCQ.Multiplier * (Int(rMin) + Int(rMax) + 1) / 2)
                    let g = UInt8(MMCQ.Multiplier * (Int(gMin) + Int(gMax) + 1) / 2)
                    let b = UInt8(MMCQ.Multiplier * (Int(bMin) + Int(bMax) + 1) / 2)
                    average = Color(r: r, g: g, b: b)
                }
            }

            return average!
        }

        func widestColorChannel() -> ColorChannel {
            let rWidth = rMax - rMin
            let gWidth = gMax - gMin
            let bWidth = bMax - bMin
            let maxWidth = max(rWidth, gWidth, bWidth)
            if maxWidth == rWidth {
                return .r
            } else if maxWidth == gWidth {
                return .g
            } else {
                return .b
            }
        }

    }

    /// Color map.
    public class ColorMap {

        var vboxes = [VBox]()

        func push(vbox: VBox) {
            vboxes.append(vbox)
        }

        public func palette() -> [Color] {
            return vboxes.map { $0.getAverage() }
        }

        public func nearest(color color: Color) -> Color {
            var nearestDistance = DBL_MAX
            var nearestColor = Color(r: 0, g: 0, b: 0)

            for vbox in vboxes {
                let vbColor = vbox.getAverage()
                let r2 = pow(Double(color.r - vbColor.r), 2.0)
                let g2 = pow(Double(color.g - vbColor.g), 2.0)
                let b2 = pow(Double(color.b - vbColor.b), 2.0)
                let distance = sqrt(r2 + g2 + b2)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestColor = vbColor
                }
            }

            return nearestColor
        }
    }

    /// Histo (1-d array, giving the number of pixels in each quantized region of color space), or null on error.
    private static func getHistogramOfPixels(pixels: [UInt8]) -> [Int] {
        var histogram = [Int](count: HistogramSize, repeatedValue: 0)
        for i in 0.stride(to: pixels.count, by: 4) {
            let r = pixels[i + 0] >> UInt8(RightShift)
            let g = pixels[i + 1] >> UInt8(RightShift)
            let b = pixels[i + 2] >> UInt8(RightShift)
            let index = MMCQ.getColorIndexOfRed(Int(r), green: Int(g), blue: Int(b))
            histogram[index] += 1
        }
        return histogram
    }

    private static func vboxFromPixels(pixels: [UInt8], histogram: [Int]) -> VBox {
        var rMin = UInt8.max
        var rMax = UInt8.min
        var gMin = UInt8.max
        var gMax = UInt8.min
        var bMin = UInt8.max
        var bMax = UInt8.min

        // find min/max
        for i in 0.stride(to: pixels.count, by: 4) {
            let r = pixels[i + 0] >> UInt8(RightShift)
            let g = pixels[i + 1] >> UInt8(RightShift)
            let b = pixels[i + 2] >> UInt8(RightShift)
            rMin = min(rMin, r)
            rMax = max(rMax, r)
            gMin = min(gMin, g)
            gMax = max(gMax, g)
            bMin = min(bMin, b)
            bMax = max(bMax, b)
        }

        return VBox(rMin: rMin, rMax: rMax, gMin: gMin, gMax: gMax, bMin: bMin, bMax: bMax, histogram: histogram)
    }

    private static func medianCutApplyWithHistogram(histogram: [Int], vbox: VBox) -> [VBox?]? {
        guard vbox.getCount() != 0 else { return nil }
        // only one pixel, no split
        guard vbox.getCount() != 1 else { return [vbox.clone(), nil] }

        // Find the partial sum arrays along the selected axis.
        var total = 0
        var partialSum = [Int](count: VBoxLength, repeatedValue: -1) // -1 = not set / 0 = 0

        let axis = vbox.widestColorChannel()
        switch axis {
        case .r:
            for i in Int(vbox.rMin) ... Int(vbox.rMax) {
                var sum = 0
                for j in Int(vbox.gMin) ... Int(vbox.gMax) {
                    for k in Int(vbox.bMin) ... Int(vbox.bMax) {
                        let index = MMCQ.getColorIndexOfRed(i, green: j, blue: k)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
            }
        case .g:
            for i in Int(vbox.gMin) ... Int(vbox.gMax) {
                var sum = 0
                for j in Int(vbox.rMin) ... Int(vbox.rMax) {
                    for k in Int(vbox.bMin) ... Int(vbox.bMax) {
                        let index = MMCQ.getColorIndexOfRed(j, green: i, blue: k)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
            }
        case .b:
            for i in Int(vbox.bMin) ... Int(vbox.bMax) {
                var sum = 0
                for j in Int(vbox.rMin) ... Int(vbox.rMax) {
                    for k in Int(vbox.gMin) ... Int(vbox.gMax) {
                        let index = MMCQ.getColorIndexOfRed(j, green: k, blue: i)
                        sum += histogram[index]
                    }
                }
                total += sum
                partialSum[i] = total
            }
        }

        var lookAheadSum = [Int](count: VBoxLength, repeatedValue: -1) // -1 = not set / 0 = 0
        for i in 0 ..< VBoxLength where partialSum[i] != -1 {
            lookAheadSum[i] = total - partialSum[i]
        }

        return doCutByAxis(axis, vbox: vbox, partialSum: partialSum, lookAheadSum: lookAheadSum, total: total)
    }

    private static func doCutByAxis(axis: ColorChannel, vbox: VBox, partialSum: [Int], lookAheadSum: [Int], total: Int) -> [VBox?] {
        let vboxMin: UInt8
        let vboxMax: UInt8

        switch axis {
        case .r:
            vboxMin = vbox.rMin
            vboxMax = vbox.rMax
        case .g:
            vboxMin = vbox.gMin
            vboxMax = vbox.gMax
        case .b:
            vboxMin = vbox.bMin
            vboxMax = vbox.bMax
        }

        for i in vboxMin ... vboxMax where partialSum[Int(i)] > total / 2 {
            let vbox1 = vbox.clone()
            let vbox2 = vbox.clone()

            let left = i - vboxMin
            let right = vboxMax - i

            var d2: UInt8
            if left <= right {
                d2 = min(vboxMax - 1, i + right / 2)
            } else {
                // 2.0 and cast to int is necessary to have the same
                // behaviour as in JavaScript
                d2 = max(vboxMin, UInt8(Double(i - 1) - Double(left) / 2.0))
            }

            // avoid 0-count
            while d2 < 0 || partialSum[Int(d2)] <= 0 {
                d2 += 1
            }
            var count2 = lookAheadSum[Int(d2)]
            while count2 == 0 && d2 > 0 && partialSum[Int(d2) - 1] > 0 {
                d2 -= 1
                count2 = lookAheadSum[Int(d2)]
            }

            // set dimensions
            switch axis {
            case .r:
                vbox1.rMax = d2
                vbox2.rMin = d2 + 1
            case .g:
                vbox1.gMax = d2
                vbox2.gMin = d2 + 1
            case .b:
                vbox1.bMax = d2
                vbox2.bMin = d2 + 1
            }

            return [vbox1, vbox2]
        }

        fatalError("VBox can't be cut")
    }

    static func quantizePixels(pixels: [UInt8], maxColors: Int) -> ColorMap? {
        // short-circuit
        guard pixels.count != 0 && maxColors > 1 && maxColors <= 256 else { return nil }

        let histogram = getHistogramOfPixels(pixels)

        // get the beginning vbox from the colors
        let vbox = vboxFromPixels(pixels, histogram: histogram)
        var pq = [vbox] // priority queue

        // Round up to have the same behaviour as in JavaScript
        let target = Int(ceil(FractionByPopulation * Double(maxColors)))

        // first set of colors, sorted by population
        iterateOnQueue(&pq, comparator: compareByCount, target: target, histogram: histogram)

        // Re-sort by the product of pixel occupancy times the size in color space.
        pq.sortInPlace(compareByProduct)

        // next set - generate the median cuts using the (npix * vol) sorting.
        iterateOnQueue(&pq, comparator: compareByProduct, target: maxColors - pq.count, histogram: histogram)

        // Reverse to put the highest elements first into the color map
        pq = pq.reverse()

        // calculate the actual colors
        let colorMap = ColorMap()
        pq.forEach { colorMap.push($0) }
        return colorMap
    }

    // Inner function to do the iteration.
    private static func iterateOnQueue(inout queue: [VBox], comparator: (VBox, VBox) -> Bool, target: Int, histogram: [Int]) {
        var color = 1
        var iteration = 0

        while iteration < MaxIterations {
            let vbox = queue.last!
            if vbox.getCount() == 0 {
                queue.sortInPlace(comparator)
                iteration += 1
                continue
            }
            queue.removeLast()

            // do the cut
            let vboxes = medianCutApplyWithHistogram(histogram, vbox: vbox)
            let vbox1: VBox! = vboxes?[0]
            let vbox2: VBox! = vboxes?[1]
            if vbox1 == nil {
                fatalError("vbox1 not defined; shouldn't happen!")
            }
            queue.append(vbox1)

            if vbox2 != nil {
                queue.append(vbox2)
                color += 1
            }
            queue.sortInPlace(comparator)

            if color >= target {
                return
            }
            if iteration > MaxIterations {
                return
            }
            iteration += 1
        }
    }

    private static func compareByCount(a: VBox, _ b: VBox) -> Bool {
        return a.getCount() < b.getCount()
    }

    private static func compareByProduct(a: VBox, _ b: VBox) -> Bool {
        let aCount = a.getCount()
        let bCount = b.getCount()
        let aVolume = a.getVolume()
        let bVolume = b.getVolume()

        if aCount == bCount {
            // If count is 0 for both (or the same), sort by volume
            return aVolume < bVolume
        } else {
            // Otherwise sort by products
            return aCount * aVolume < bCount * bVolume
        }
    }

}
