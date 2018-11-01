import UIKit

internal class SeparatorLineDrawingView: UIView {
    
    var settings: SeparatorLines = SeparatorLines()
    
    // PRIVATE PROPERTIES
    // ##################
    
    private var labelMargin: CGFloat = 4
    private var leftLabelInset: CGFloat = 10
    private var rightLabelInset: CGFloat = 10
    private var offset: CGFloat = 0
    
    // Store information about the ScrollableGraphView
    private var currentRange: (min: Double, max: Double) = (0, 100)
    private var topMargin: CGFloat = 10
    private var bottomMargin: CGFloat = 10
    
    private var lineWidth: CGFloat {
        get {
            return self.bounds.width
        }
    }
    
    // Layers
    private var labels = [UILabel]()
    private let separatorLineLayer = CAShapeLayer()
    private let separatorLinePath = UIBezierPath()
    
    init(frame: CGRect, topMargin: CGFloat, bottomMargin: CGFloat, separatorLineColor: UIColor, separatorLineThickness: CGFloat, separatorLineSettings: SeparatorLines) {
        super.init(frame: frame)
        
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        
        // The separator line layer draws the separator lines and we handle the labels elsewhere.
        self.separatorLineLayer.frame = self.frame
        self.separatorLineLayer.strokeColor = separatorLineColor.cgColor
        self.separatorLineLayer.lineWidth = separatorLineThickness
        
        self.settings = separatorLineSettings
        
        self.layer.addSublayer(separatorLineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLabel(at position: CGPoint, withText text: String) -> UILabel {
        let frame = CGRect(x: position.x, y: position.y, width: 0, height: 0)
        let label = UILabel(frame: frame)
        
        return label
    }
    
    private func createSeparatorLinesPath() -> UIBezierPath {
        
        separatorLinePath.removeAllPoints()
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        // add vertical line from top to bottom
        let xPosition = self.settings.separatorLinePositionX - self.frame.origin.x
        let maxLineStart = CGPoint(x: xPosition, y: topMargin)
        let maxLineEnd = CGPoint(x: xPosition, y: self.frame.height - bottomMargin - topMargin - self.settings.separatorLineLabelFont!.pointSize)
        
        addLine(from: maxLineStart, to: maxLineEnd, in: separatorLinePath)
        
        // add text
        let boundingSizeLeft = self.boundingSize(forText: self.settings.leftLabel)
        let boundingSizeRight = self.boundingSize(forText: self.settings.rightLabel)
        let leftLabel = createLabel(withText: self.settings.leftLabel)
        let rightLabel = createLabel(withText: self.settings.rightLabel)
        leftLabel.frame = CGRect(
            origin: CGPoint(x: xPosition - boundingSizeLeft.width - 10, y: topMargin),
            size: boundingSizeLeft)
        
        self.addSubview(leftLabel)
        self.labels.append(leftLabel)
        
        rightLabel.frame = CGRect(
            origin: CGPoint(x: xPosition + 10, y: topMargin),
            size: boundingSizeRight)
        
        self.addSubview(rightLabel)
        self.labels.append(rightLabel)
        
        // add vertical line
        let yPosition = calculateYPositionForYAxisValue(value: self.settings.separatorLinePositionY)
        let verticalLabelViewSize = self.settings.separatorLinePositionYLabel?.frame.size
        let lineStart = CGPoint(x: (verticalLabelViewSize?.width ?? 0) + 10, y: yPosition)
        let lineEnd = CGPoint(x: lineStart.x + lineWidth, y: yPosition)
        
        let verticalLabel = self.settings.separatorLinePositionYLabel
        verticalLabel?.frame.origin.x = 5
        verticalLabel?.frame.origin.y = yPosition - (verticalLabelViewSize?.height ?? 0) / 2
        self.addSubview(verticalLabel!)
        
        addLine(from: lineStart, to: lineEnd, in: separatorLinePath)
        return separatorLinePath
    }
    
    private func addLine(from: CGPoint, to: CGPoint, in path: UIBezierPath) {
        path.move(to: from)
        path.addLine(to: to)
    }
    
    private func boundingSize(forText text: String) -> CGSize {
        return (text as NSString).size(withAttributes:
            [NSAttributedString.Key.font: self.settings.separatorLineLabelFont])
    }
    
    private func calculateYPositionForYAxisValue(value: Double) -> CGFloat {
        // Just an algebraic re-arrangement of calculateYAxisValue
        let graphHeight = self.frame.size.height - (topMargin + bottomMargin)
        var y = ((CGFloat(value - self.currentRange.max) / CGFloat(self.currentRange.min - self.currentRange.max)) * graphHeight) + topMargin
        
        if (y == 0) {
            y = 0
        }
        
        return y
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.text = text
        label.textColor = self.settings.separatorLineLabelColor
        label.font = self.settings.separatorLineLabelFont
        
        return label
    }
    
    // Public functions to update the separator lines with any changes to the range and viewport (phone rotation, etc).
    // When the range changes, need to update the max for the new range, then update all the labels that are showing for the axis and redraw the separator lines.
    func set(range: (min: Double, max: Double)) {
        self.currentRange = range
        self.separatorLineLayer.path = createSeparatorLinesPath().cgPath
    }
    
    func set(offset: CGFloat) {
        self.offset = offset
        self.separatorLineLayer.path = createSeparatorLinesPath().cgPath
    }
    
    func set(viewportWidth: CGFloat, viewportHeight: CGFloat) {
        self.frame.size.width = viewportWidth
        self.frame.size.height = viewportHeight
        self.separatorLineLayer.path = createSeparatorLinesPath().cgPath
    }
}
