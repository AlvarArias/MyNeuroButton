import NeumorphicCore
import SwiftUI

/// Sunken text field with an optional leading SF Symbol, a focus ring and an error state.
///
/// The field sits in an inset surface (`NeumorphicInset`). While focused it draws a ring in
/// `focusColor`; while `isError` is `true` the ring uses `errorColor` instead, and
/// `errorMessage` appears under the field and is read by VoiceOver as the field's hint.
///
/// Keyboard and input traits are not parameters: apply the usual SwiftUI modifiers to the
/// field, since they reach the text field inside it, e.g. `.keyboardType(.emailAddress)`,
/// `.textInputAutocapitalization(.never)`, `.submitLabel(.done)` and `.onSubmit { }`.
///
/// The inner shadow stays inside the field, but the focus ring and error message extend a
/// little past it; leave room around the field inside clipped containers.
@MainActor
public struct NeuroTextField: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isFocused: Bool

    // MARK: - Public Properties

    /// Placeholder shown while the field is empty. Also the VoiceOver label.
    public let title: LocalizedStringKey

    /// Text being edited
    public let text: Binding<String>

    /// Optional SF Symbol shown before the text. Hidden from VoiceOver.
    public let systemImage: String?

    /// Hides the typed characters (password entry)
    public let isSecure: Bool

    /// Marks the field as invalid: draws the error ring and shows `errorMessage`
    public let isError: Bool

    /// Text shown under the field while `isError` is `true`
    public let errorMessage: LocalizedStringKey?

    /// Ring color while focused
    public let focusColor: Color

    /// Ring color while `isError` is `true`
    public let errorColor: Color

    /// Minimum height of the field
    public let fieldHeight: CGFloat

    private let explicitTheme: NeumorphicTheme?

    /// Theme given at init, or `.default` when none was given. When none was given the
    /// environment theme is applied at render time (ADR-003), which this property cannot see.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    // MARK: - Initialization

    /// - Parameters:
    ///   - title: Placeholder and VoiceOver label; looked up as a localization key.
    ///   - text: Binding to the edited text.
    ///   - systemImage: Optional SF Symbol shown before the text.
    ///   - isSecure: Hides the typed characters.
    ///   - isError: Draws the error ring and shows `errorMessage`.
    ///   - errorMessage: Text under the field while `isError` is `true`.
    ///   - focusColor: Ring color while focused.
    ///   - errorColor: Ring color while in error.
    ///   - fieldHeight: Minimum height of the field.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        systemImage: String? = nil,
        isSecure: Bool = false,
        isError: Bool = false,
        errorMessage: LocalizedStringKey? = nil,
        focusColor: Color = .blue,
        errorColor: Color = .red,
        fieldHeight: CGFloat = 44,
        theme: NeumorphicTheme? = nil
    ) {
        self.title = title
        self.text = text
        self.systemImage = systemImage
        self.isSecure = isSecure
        self.isError = isError
        self.errorMessage = errorMessage
        self.focusColor = focusColor
        self.errorColor = errorColor
        self.fieldHeight = fieldHeight
        self.explicitTheme = theme
    }

    // MARK: - Body

    public var body: some View {
        let resolved = explicitTheme ?? environmentTheme
        let shape = RoundedRectangle(cornerRadius: resolved.cornerRadius)

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(resolved.foreground.opacity(0.7))
                        .accessibilityHidden(true)
                }
                field
                    .foregroundStyle(resolved.foreground)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: fieldHeight)
            .neumorphicInset(in: shape, theme: resolved)
            .overlay {
                shape
                    .strokeBorder(ringColor ?? .clear, lineWidth: 2)
            }
            .contentShape(shape)
            .onTapGesture { isFocused = true }
            .animation(animation(for: resolved), value: isFocused)
            .animation(animation(for: resolved), value: isError)

            if isError, let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(errorColor)
                    .padding(.horizontal, 4)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Private Helpers

    @ViewBuilder
    private var field: some View {
        if isSecure {
            SecureField(title, text: text)
                .focused($isFocused)
                .accessibilityHint(hint)
        } else {
            TextField(title, text: text)
                .focused($isFocused)
                .accessibilityHint(hint)
        }
    }

    /// The error message is hidden from VoiceOver as a separate element and read as the hint.
    private var hint: Text {
        isError ? errorMessage.map { Text($0) } ?? Text("") : Text("")
    }

    /// Error wins over focus: an invalid field stays red while it is being edited.
    private var ringColor: Color? {
        if isError { return errorColor }
        return isFocused ? focusColor : nil
    }

    private func animation(for theme: NeumorphicTheme) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: theme.animationDuration)
    }
}
