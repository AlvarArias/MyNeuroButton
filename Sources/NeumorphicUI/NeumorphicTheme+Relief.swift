import NeumorphicCore
import SwiftUI

extension NeumorphicTheme {
    /// Copy of the theme whose raised and pressed shadows never exceed `radius`.
    /// Small elements (badges, slider knobs, segmented-control pills) use it so the shadow does not swallow them.
    func cappingShadow(at radius: CGFloat) -> NeumorphicTheme {
        var capped = self
        capped.normalShadowRadius = min(normalShadowRadius, radius)
        capped.pressedShadowRadius = min(pressedShadowRadius, radius)
        return capped
    }
}
