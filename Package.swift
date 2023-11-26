// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ColorThiefSwift",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "ColorThiefSwift", targets: ["ColorThiefSwift"])
    ],
    targets: [
        .target(
            name: "ColorThiefSwift",
            path: "ColorThiefSwift/Classes"
        )
    ]
)
