import UIKit

internal class LineDrawingLayer: ScrollableGraphViewDrawingLayer {

    private var currentLinePath = UIBezierPath()

    private var lineStyle: ScrollableGraphViewLineStyle
    private var lineStrokeStyle: ScrollableGraphViewLineStrokeStyle
    private var shouldFill: Bool
    private var lineCurviness: CGFloat

    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineStyle: ScrollableGraphViewLineStyle, lineStrokeStyle: ScrollableGraphViewLineStrokeStyle, lineJoin: String, lineCap: String, shouldFill: Bool, lineCurviness: CGFloat) {

        self.lineStyle = lineStyle
        self.lineStrokeStyle = lineStrokeStyle
        self.shouldFill = shouldFill
        self.lineCurviness = lineCurviness

        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)

        self.lineWidth = lineWidth
        self.strokeColor = lineColor.cgColor

        self.lineJoin = convertToCAShapeLayerLineJoin(lineJoin)
        self.lineCap = convertToCAShapeLayerLineCap(lineCap)

        // Setup
        self.fillColor = UIColor.clear.cgColor // This is handled by the fill drawing layer.

        if lineStrokeStyle == .dashed {
            self.lineDashPattern = [5.0, 5.0]
            self.lineDashPhase = 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func createLinePath() -> UIBezierPath {

        guard let owner = owner else {
            return UIBezierPath()
        }

        // Can't really do anything without the delegate.
        guard let delegate = self.owner?.graphViewDrawingDelegate else {
            return currentLinePath
        }

        currentLinePath.removeAllPoints()

        let pathSegmentAdder = lineStyle == .straight ? addStraightLineSegment : addCurvedLineSegment

        let activePointsInterval = delegate.intervalForActivePoints()
        let min = delegate.rangeForActivePoints().min
        zeroYPosition = delegate.calculatePosition(atIndex: 0, value: min).y

        // find first not nil point
        var firstNotNilPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
        var lastNotNilPoint = owner.graphPoint(forIndex: activePointsInterval.upperBound - 1)
        for i in activePointsInterval.lowerBound ..< activePointsInterval.upperBound - 1 {
            let point = owner.graphPoint(forIndex: i)
            if point != nil && firstNotNilPoint == nil {
                firstNotNilPoint = point
            }
            if point != nil {
                lastNotNilPoint = point
            }
        }
        if (firstNotNilPoint == nil) {
            return currentLinePath
        }
        // Connect the line to the starting edge if we are filling it.
        if(shouldFill) {
            // Add a line from the base of the graph to the first data point.
            let leftBottom = CGPoint(x: firstNotNilPoint!.location.x, y: zeroYPosition)
            currentLinePath.move(to: leftBottom)

            pathSegmentAdder(leftBottom, CGPoint(x: firstNotNilPoint!.location.x, y: firstNotNilPoint!.location.y), currentLinePath)
        } else {
            currentLinePath.move(to: firstNotNilPoint!.location)
        }

        // Connect each point on the graph with a segment.
        var lastNotNilDataPoint = firstNotNilPoint?.location
        for i in activePointsInterval.lowerBound ..< activePointsInterval.upperBound - 1 {
            let startPoint = owner.graphPoint(forIndex: i)
            let endPoint = owner.graphPoint(forIndex: i+1)
            if (startPoint != nil && endPoint == nil) {
                lastNotNilDataPoint = CGPoint(x: startPoint!.location.x, y: zeroYPosition)
                pathSegmentAdder(startPoint!.location, lastNotNilDataPoint!, currentLinePath)
            }
            if (startPoint == nil && endPoint != nil) {
                pathSegmentAdder(lastNotNilDataPoint!, CGPoint(x: endPoint!.location.x, y: zeroYPosition), currentLinePath)
                pathSegmentAdder(CGPoint(x: endPoint!.location.x, y: zeroYPosition), endPoint!.location, currentLinePath)
            }
            if (startPoint != nil && endPoint != nil) {
                pathSegmentAdder(startPoint!.location, endPoint!.location, currentLinePath)
            }
        }

        // Connect the line to the ending edge if we are filling it.
        if(shouldFill) {
            // Add a line from the last data point to the base of the graph.
            let rightBottom = CGPoint(x: lastNotNilPoint!.x, y: zeroYPosition)

            pathSegmentAdder(lastNotNilPoint!.location, rightBottom, currentLinePath)
        }

        return currentLinePath
    }

    private func addStraightLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        path.addLine(to: endPoint)
    }

    private func addCurvedLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        // calculate control points
        let difference = endPoint.x - startPoint.x

        var x = startPoint.x + (difference * lineCurviness)
        var y = startPoint.y
        let controlPointOne = CGPoint(x: x, y: y)

        x = endPoint.x - (difference * lineCurviness)
        y = endPoint.y
        let controlPointTwo = CGPoint(x: x, y: y)

        // add curve from start to end
        currentLinePath.addCurve(to: endPoint, controlPoint1: controlPointOne, controlPoint2: controlPointTwo)
    }

    override func updatePath() {
        self.path = createLinePath().cgPath
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToCAShapeLayerLineJoin(_ input: String) -> CAShapeLayerLineJoin {
	return CAShapeLayerLineJoin(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}
