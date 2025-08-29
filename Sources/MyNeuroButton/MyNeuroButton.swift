
import SwiftUI

/// A customizable button with neumorphic design and SF Symbol icon support.
///
/// MyNeuroButton provides a modern neumorphic-style button with smooth animations,
/// customizable colors, and support for SF Symbols. The button features a pressed
/// state with visual feedback and haptic-like shadows.
///
/// Example usage:
/// ```swift
/// MyNeuroButton(
///     icon: "star",
///     iconFilled: "star.fill",
///     fillColor: .blue,
///     width: 100,
///     height: 100
/// ) {
///     print("Button tapped!")
/// }
/// ```
public struct MyNeuroButton: View {
    
    // MARK: - Private Properties
    
    @State private var isPressed = false
   
    // MARK: - Public Properties
    
    /// The SF Symbol name to display when the button is not pressed
    public let icon: String
    
    /// The SF Symbol name to display when the button is pressed
    public let iconFilled: String
    
    /// The background color when the button is pressed
    public let fillColor: Color
    
    /// The width of the button
    public let width: CGFloat
    
    /// The height of the button
    public let height: CGFloat
    
    /// The action to perform when the button is tapped
    public let action: () -> Void
    
    // MARK: - Initialization
    
    /// Creates a neumorphic button with customizable appearance and behavior.
    ///
    /// - Parameters:
    ///   - icon: SF Symbol name for the normal state
    ///   - iconFilled: SF Symbol name for the pressed state
    ///   - fillColor: Background color when pressed (default: .blue)
    ///   - width: Button width in points (default: 100)
    ///   - height: Button height in points (default: 100)
    ///   - action: Closure to execute when the button is tapped
    public init(
        icon: String,
        iconFilled: String,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconFilled = iconFilled
        self.fillColor = fillColor
        self.width = width
        self.height = height
        self.action = action
    }
    
    /// Creates a neumorphic button with legacy parameter names for backward compatibility.
    ///
    /// - Note: This initializer is deprecated. Use `init(icon:iconFilled:fillColor:width:height:action:)` instead.
    ///
    /// - Parameters:
    ///   - icon: SF Symbol name for the normal state
    ///   - iconFull: SF Symbol name for the pressed state
    ///   - fillColor: Background color when pressed (default: .blue)
    ///   - height: Button height in points (default: 100)
    ///   - width: Button width in points (default: 100)
    ///   - action: Closure to execute when the button is tapped
    @available(*, deprecated, message: "Use init(icon:iconFilled:fillColor:width:height:action:) instead")
    public init(
        icon: String,
        iconFull: String,
        fillColor: Color = .blue,
        height: CGFloat = 100,
        width: CGFloat = 100,
        action: @escaping () -> Void
    ) {
        self.init(
            icon: icon,
            iconFilled: iconFull,
            fillColor: fillColor,
            width: width,
            height: height,
            action: action
        )
    }
    

    // MARK: - Body
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPressed ? fillColor : Color.neumorphicBackground)
                
                Image(systemName: isPressed ? iconFilled : icon)
                    .foregroundColor(isPressed ? .white : .neumorphicForeground)
                    .font(.title2)
            }
            .frame(width: width, height: height)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color.black.opacity(isPressed ? 0.1 : 0.3),
                radius: isPressed ? 5 : 10,
                x: isPressed ? 5 : 10,
                y: isPressed ? 5 : 10
            )
            .shadow(
                color: Color.white.opacity(isPressed ? 0.4 : 0.8),
                radius: isPressed ? 5 : 10,
                x: isPressed ? -2 : -5,
                y: isPressed ? -2 : -5
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Color Extensions

public extension Color {
    /// The default background color for neumorphic design
    static let neumorphicBackground = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    
    /// The default foreground color for neumorphic design
    static let neumorphicForeground = Color(red: 100 / 255, green: 100 / 255, blue: 110 / 255)
}

