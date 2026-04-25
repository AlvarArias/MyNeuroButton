// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MyNeuroButton",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26)
    ],
    products: [
        .library(name: "MyNeuroButton", targets: ["MyNeuroButton"])
    ],
    targets: [
        .target(name: "MyNeuroButton"),
        .testTarget(name: "MyNeuroButtonTests", dependencies: ["MyNeuroButton"])
    ]
)
