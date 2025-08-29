
import SwiftUI

public struct MyNeuroButton: View {
    
    /// Un botón con diseño neuromórfico y soporte de icono SF Symbol.
    @State private var isPressed = false
   
    public let icon: String
    public let iconFull: String
    public let fillColor: Color
    public let height: CGFloat
    public let width: CGFloat
    public let action: () -> Void
    
    
    /// Crea un botón neuromórfico.
    /// - Parameters:
    ///   - icon: SF Symbol para el estado normal.
    ///   - iconFull: SF Symbol para el estado presionado.
    ///   - fillColor: Color de fondo cuando se presiona.
    ///   - height: Alto del botón.
    ///   - width: Ancho del botón.
    ///   - action: Acción al presionar.
    public init(
        icon: String,
        iconFull: String,
        fillColor: Color = .blue,
        height: CGFloat = 100,
        width: CGFloat = 100,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconFull = iconFull
        self.fillColor = fillColor
        self.height = height
        self.width = width
        self.action = action
    }
    

public var body: some View {
    Button(action: {
        isPressed.toggle()
        if isPressed { action() }
    }) {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isPressed ? fillColor : Color.offWhite)
            Image(systemName: isPressed ? iconFull : icon)
                .foregroundColor(isPressed ? .white : .gray)
        }
        .frame(width: width, height: height)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
        .shadow(color: Color.white.opacity(0.8), radius: 10, x: -5, y: -5)
    }
    .buttonStyle(PlainButtonStyle())
}
}

public extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

