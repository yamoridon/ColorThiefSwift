// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ColorThiefSwift",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v4),
        .macOS(.v10_13)
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
