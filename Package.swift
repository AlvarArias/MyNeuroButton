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
        .library(name: "MyNeuroButton", targets: ["MyNeuroButton"])
    ],
    targets: [
        .target(name: "NeumorphicCore"),
        .target(name: "MyNeuroButton", dependencies: ["NeumorphicCore"]),
        .testTarget(name: "MyNeuroButtonTests", dependencies: ["MyNeuroButton"])
    ]
)
