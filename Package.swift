// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ColorThiefSwift",
    platforms: [.iOS(.v10)],
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
