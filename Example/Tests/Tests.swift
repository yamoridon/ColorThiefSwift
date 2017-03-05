import ColorThiefSwift
import UIKit
import XCTest

class Tests: XCTestCase {

    var image: UIImage!

    override func setUp() {
        super.setUp()
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "pen", ofType: "jpg")!
        image = UIImage(contentsOfFile: path)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetColor1() {
        let color = ColorThief.getColor(from: image, quality: 20, ignoreWhite: true)
        XCTAssertNotNil(color)
        if let color = color {
            XCTAssertEqual(color.r, 31)
            XCTAssertEqual(color.g, 99)
            XCTAssertEqual(color.b, 100)
        }
    }

    func testGetColor2() {
        let color = ColorThief.getColor(from: image, quality: 20, ignoreWhite: false)
        XCTAssertNotNil(color)
        if let color = color {
            XCTAssertEqual(color.r, 35)
            XCTAssertEqual(color.g, 97)
            XCTAssertEqual(color.b, 98)
        }
    }

    func testGetColor3() {
        let color = ColorThief.getColor(from: image, quality: 1, ignoreWhite: true)
        XCTAssertNotNil(color)
        if let color = color {
            XCTAssertEqual(color.r, 31)
            XCTAssertEqual(color.g, 100)
            XCTAssertEqual(color.b, 100)
        }
    }

    func testGetColor4() {
        let color = ColorThief.getColor(from: image, quality: 1, ignoreWhite: false)
        XCTAssertNotNil(color)
        if let color = color {
            XCTAssertEqual(color.r, 35)
            XCTAssertEqual(color.g, 98)
            XCTAssertEqual(color.b, 98)
        }
    }

    func testGetPalette1() {
        let palette = ColorThief.getPalette(from: image, colorCount: 10, quality: 20, ignoreWhite: true)
        XCTAssertNotNil(palette)
        if let palette = palette {
            XCTAssertEqual(palette.count, 9)
            if palette.count == 9 {
                XCTAssertEqual(palette[0].r, 34)
                XCTAssertEqual(palette[0].g, 81)
                XCTAssertEqual(palette[0].b, 80)
                XCTAssertEqual(palette[1].r, 187)
                XCTAssertEqual(palette[1].g, 31)
                XCTAssertEqual(palette[1].b, 43)
                XCTAssertEqual(palette[2].r, 224)
                XCTAssertEqual(palette[2].g, 148)
                XCTAssertEqual(palette[2].b, 42)
                XCTAssertEqual(palette[3].r, 234)
                XCTAssertEqual(palette[3].g, 227)
                XCTAssertEqual(palette[3].b, 218)
                XCTAssertEqual(palette[4].r, 181)
                XCTAssertEqual(palette[4].g, 121)
                XCTAssertEqual(palette[4].b, 136)
                XCTAssertEqual(palette[5].r, 19)
                XCTAssertEqual(palette[5].g, 191)
                XCTAssertEqual(palette[5].b, 197)
                XCTAssertEqual(palette[6].r, 204)
                XCTAssertEqual(palette[6].g, 165)
                XCTAssertEqual(palette[6].b, 123)
                XCTAssertEqual(palette[7].r, 202)
                XCTAssertEqual(palette[7].g, 167)
                XCTAssertEqual(palette[7].b, 188)
                XCTAssertEqual(palette[8].r, 137)
                XCTAssertEqual(palette[8].g, 185)
                XCTAssertEqual(palette[8].b, 188)
            }
        }
    }

    func testGetPalette2() {
        let palette = ColorThief.getPalette(from: image, colorCount: 10, quality: 20, ignoreWhite: false)
        XCTAssertNotNil(palette)
        if let palette = palette {
            XCTAssertEqual(palette.count, 9)
            if palette.count == 9 {
                XCTAssertEqual(palette[0].r, 38)
                XCTAssertEqual(palette[0].g, 73)
                XCTAssertEqual(palette[0].b, 75)
                XCTAssertEqual(palette[1].r, 190)
                XCTAssertEqual(palette[1].g, 36)
                XCTAssertEqual(palette[1].b, 45)
                XCTAssertEqual(palette[2].r, 224)
                XCTAssertEqual(palette[2].g, 154)
                XCTAssertEqual(palette[2].b, 53)
                XCTAssertEqual(palette[3].r, 243)
                XCTAssertEqual(palette[3].g, 239)
                XCTAssertEqual(palette[3].b, 235)
                XCTAssertEqual(palette[4].r, 24)
                XCTAssertEqual(palette[4].g, 187)
                XCTAssertEqual(palette[4].b, 181)
                XCTAssertEqual(palette[5].r, 188)
                XCTAssertEqual(palette[5].g, 134)
                XCTAssertEqual(palette[5].b, 151)
                XCTAssertEqual(palette[6].r, 219)
                XCTAssertEqual(palette[6].g, 183)
                XCTAssertEqual(palette[6].b, 144)
                XCTAssertEqual(palette[7].r, 153)
                XCTAssertEqual(palette[7].g, 188)
                XCTAssertEqual(palette[7].b, 184)
                XCTAssertEqual(palette[8].r, 210)
                XCTAssertEqual(palette[8].g, 184)
                XCTAssertEqual(palette[8].b, 199)
            }
        }
    }

    func testGetPalette3() {
        let palette = ColorThief.getPalette(from: image, colorCount: 10, quality: 1, ignoreWhite: true)
        XCTAssertNotNil(palette)
        if let palette = palette {
            XCTAssertEqual(palette.count, 9)
            if palette.count == 9 {
                XCTAssertEqual(palette[0].r, 34)
                XCTAssertEqual(palette[0].g, 81)
                XCTAssertEqual(palette[0].b, 80)
                XCTAssertEqual(palette[1].r, 187)
                XCTAssertEqual(palette[1].g, 31)
                XCTAssertEqual(palette[1].b, 43)
                XCTAssertEqual(palette[2].r, 224)
                XCTAssertEqual(palette[2].g, 148)
                XCTAssertEqual(palette[2].b, 43)
                XCTAssertEqual(palette[3].r, 234)
                XCTAssertEqual(palette[3].g, 227)
                XCTAssertEqual(palette[3].b, 219)
                XCTAssertEqual(palette[4].r, 182)
                XCTAssertEqual(palette[4].g, 121)
                XCTAssertEqual(palette[4].b, 137)
                XCTAssertEqual(palette[5].r, 19)
                XCTAssertEqual(palette[5].g, 192)
                XCTAssertEqual(palette[5].b, 198)
                XCTAssertEqual(palette[6].r, 206)
                XCTAssertEqual(palette[6].g, 167)
                XCTAssertEqual(palette[6].b, 123)
                XCTAssertEqual(palette[7].r, 202)
                XCTAssertEqual(palette[7].g, 167)
                XCTAssertEqual(palette[7].b, 186)
                XCTAssertEqual(palette[8].r, 137)
                XCTAssertEqual(palette[8].g, 184)
                XCTAssertEqual(palette[8].b, 187)
            }
        }
    }

    func testGetPalette4() {
        let palette = ColorThief.getPalette(from: image, colorCount: 10, quality: 1, ignoreWhite: false)
        XCTAssertNotNil(palette)
        if let palette = palette {
            XCTAssertEqual(palette.count, 9)
            if palette.count == 9 {
                XCTAssertEqual(palette[0].r, 38)
                XCTAssertEqual(palette[0].g, 73)
                XCTAssertEqual(palette[0].b, 75)
                XCTAssertEqual(palette[1].r, 190)
                XCTAssertEqual(palette[1].g, 36)
                XCTAssertEqual(palette[1].b, 46)
                XCTAssertEqual(palette[2].r, 224)
                XCTAssertEqual(palette[2].g, 154)
                XCTAssertEqual(palette[2].b, 53)
                XCTAssertEqual(palette[3].r, 243)
                XCTAssertEqual(palette[3].g, 239)
                XCTAssertEqual(palette[3].b, 235)
                XCTAssertEqual(palette[4].r, 24)
                XCTAssertEqual(palette[4].g, 187)
                XCTAssertEqual(palette[4].b, 181)
                XCTAssertEqual(palette[5].r, 188)
                XCTAssertEqual(palette[5].g, 133)
                XCTAssertEqual(palette[5].b, 151)
                XCTAssertEqual(palette[6].r, 220)
                XCTAssertEqual(palette[6].g, 183)
                XCTAssertEqual(palette[6].b, 143)
                XCTAssertEqual(palette[7].r, 154)
                XCTAssertEqual(palette[7].g, 187)
                XCTAssertEqual(palette[7].b, 186)
                XCTAssertEqual(palette[8].r, 209)
                XCTAssertEqual(palette[8].g, 185)
                XCTAssertEqual(palette[8].b, 198)
            }
        }
    }

    func testSmallWidthImage() {
        let width = 1
        let height = 16
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        context!.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let color = ColorThief.getColor(from: image!, quality: 1, ignoreWhite: false)
        XCTAssertNotNil(color)
    }

    // To generate test code.
    /*
    func testGetPalette() {
        let palette = ColorThief.getPalette(from: image, colorCount: 10, quality: 20, ignoreWhite: false)
        XCTAssertNotNil(palette)
        if let palette = palette {
            XCTAssertEqual(palette.count, 9)
            for i in 0 ..< 9 {
                print("                XCTAssertEqual(palette[\(i)].r, \(palette[i].r))")
                print("                XCTAssertEqual(palette[\(i)].g, \(palette[i].g))")
                print("                XCTAssertEqual(palette[\(i)].b, \(palette[i].b))")
            }
        }
    }
     */

    func testPerformanceGetPalette() {
        self.measure { [weak self] in
            let _ = ColorThief.getPalette(from: self!.image, colorCount: 10, quality: 1, ignoreWhite: false)
        }
    }

}
