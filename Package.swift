// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MyNeuroUI",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26)
    ],
    products: [
        .library(name: "NeumorphicCore", targets: ["NeumorphicCore"]),
        .library(name: "NeumorphicUI", targets: ["NeumorphicUI"]),
        .library(name: "MyNeuroButton", targets: ["MyNeuroButton"])
    ],
    targets: [
        .target(name: "NeumorphicCore"),
        .target(name: "NeumorphicUI", dependencies: ["NeumorphicCore"]),
        .target(name: "MyNeuroButton", dependencies: ["NeumorphicCore"]),
        .testTarget(name: "NeumorphicCoreTests", dependencies: ["NeumorphicCore"]),
        .testTarget(name: "NeumorphicUITests", dependencies: ["NeumorphicUI", "NeumorphicCore"]),
        .testTarget(name: "MyNeuroButtonTests", dependencies: ["MyNeuroButton", "NeumorphicCore"])
    ]
)
