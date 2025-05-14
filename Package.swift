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
    .package(
      url: "https://github.com/krisk/fuse-swift.git",
      from: "1.4.0"
    ),

  ],
  targets: [
    .executableTarget(
      name: "menu",
      dependencies: [
        .product(name: "SwiftProtobuf", package: "swift-protobuf"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Fuse", package: "fuse-swift"),
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-sectcreate",
          "-Xlinker", "__TEXT",
          "-Xlinker", "__info_plist",
          "-Xlinker", "Info.plist",
        ])
      ]
    ),

    .testTarget(
      name: "menuTests",
      dependencies: ["menu"]
    ),
  ]
)
