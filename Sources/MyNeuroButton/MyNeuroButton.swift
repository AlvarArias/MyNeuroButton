
/*
import SwiftUI

public struct MyNeuroButton: View {
    @State private var isClicked = false
    public var action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            self.isClicked.toggle()
            if self.isClicked { self.action() }
        }) {
            Text("Click me")
        }
    }
}
*/

import SwiftUI

public struct MyNeuroButton: View {
    
    @State private var isClick = false
   
    let icon: String
    let icon_full: String
    let fillColor: Color
    let button_height: CGFloat
    let button_width: CGFloat
    let action: () -> Void
    
    public init(icon: String, icon_full: String, fillColor: Color, button_height: CGFloat, button_width: CGFloat, action: @escaping () -> Void) {
        self.icon = icon
        self.icon_full = icon_full
        self.fillColor = fillColor
        self.button_height = button_height
        self.button_width = button_width
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            Color.offWhite
            Button(action: {
                isClick.toggle()
                if isClick { action()}
            }) {
                if isClick {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(fillColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .top, endPoint: .bottom)))
                            )
                            .padding()
                        Image(systemName: icon_full)
                            .foregroundColor(.white)
                    }
                    .frame(width: button_width, height: button_height)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.offWhite)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.8), radius: 10, x: -5, y: -5)
                            .padding()
                        Image(systemName: icon)
                            .foregroundColor(.gray)
                    }
                    .frame(width: button_width, height: button_height)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

