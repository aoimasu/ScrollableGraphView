import UIKit

// Currently just a simple data structure to hold the settings for the separator lines.
open class SeparatorLines {

    // Separator Lines
    // ###############

    /// Whether or not to show the y-axis separator lines and labels.
    @IBInspectable open var shouldShowSeparatorLines: Bool = true
    /// The colour for the separator lines.
    @IBInspectable open var separatorLineColor: UIColor = UIColor.black
    /// The thickness of the separator lines.
    @IBInspectable open var separatorLineThickness: CGFloat = 0.5

    @IBInspectable open var separatorLinePosition: Int = -1
    @IBInspectable open var separatorLinePositionX: CGFloat = 0
    @IBInspectable open var separatorLinePositionY: Double = 0
    @IBInspectable open var separatorLinePositionYLabel: UIView? = nil
    
    @IBInspectable open var leftLabel: String = ""
    @IBInspectable open var rightLabel: String = ""

    // Separator Line Labels
    // #####################
    /// Whether or not to show the labels on the x-axis for each point.
    @IBInspectable open var shouldShowLabels: Bool = true
    /// The colour for the data point labels.
    open var separatorLineLabelFont: UIFont? = UIFont.systemFont(ofSize: 10)
    /// The colour of the separator line labels.
    @IBInspectable open var separatorLineLabelColor: UIColor = UIColor.white

    public init() {
        // Need this for external frameworks.
    }
}
