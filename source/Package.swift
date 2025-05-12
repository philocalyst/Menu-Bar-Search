// swift-tools-version:6.1
import PackageDescription

let package = Package(
  name: "menu",
  platforms: [.macOS(.v10_15)],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-protobuf.git",
      from: "1.29.0"
    ),
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      from: "1.5.0"
    ),
  ],
  targets: [
    .executableTarget(
      name: "menu",
      dependencies: [
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
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
