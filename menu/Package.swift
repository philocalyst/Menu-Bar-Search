// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "menu",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-protobuf.git",
            from: "1.6.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "menu",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Info.plist",
                ])
            ]
        ),
        .testTarget(
            name: "menuTests",
            dependencies: ["menu"]
        ),
    ]
)
