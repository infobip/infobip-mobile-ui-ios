// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "InfobipMobileUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "InfobipMobileUI",
            targets: ["InfobipMobileUI"]
        )
    ],
    targets: [
        .target(
            name: "InfobipMobileUI",
            path: "Sources/IBCallUI"
        )
    ]
)
