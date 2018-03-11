/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit

class SwiftyRecordButton: SwiftyCamButton {
    
    private var circleBorder: CALayer!
    private var innerCircle: UIView!
    fileprivate var shapeTimer : Timer?
    /// Initialization Declaration
    fileprivate var shapeLayer : CAShapeLayer?
    fileprivate var bPath : UIBezierPath?
    fileprivate var angle : Double?
    //
    var annulusColor : UIColor?
    var annulusTime : Double?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()
    }
    
    private func drawButton() {
        self.backgroundColor = UIColor.clear
        circleBorder = CALayer()
        // initLayout()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 6.0
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = self.bounds
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
    }
    
    public  func growButton() {
        self.angle = 0
        innerCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        innerCircle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        innerCircle.backgroundColor = UIColor.red
        innerCircle.layer.cornerRadius = innerCircle.frame.size.width / 2
        innerCircle.clipsToBounds = true
        self.addSubview(innerCircle)
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
            self.innerCircle.transform = CGAffineTransform(scaleX: 62.4, y: 62.4)
            self.circleBorder.setAffineTransform(CGAffineTransform(scaleX: 1.352, y: 1.352))
            self.circleBorder.borderWidth = (6 / 1.352)
            
        }, completion: nil)
        print("start draw")
        shapeTimer = Timer.scheduledTimer(timeInterval: annulusTime!/(360/annulusTime!)/5, target: self, selector:  #selector(SwiftyRecordButton.drawShape), userInfo: nil, repeats: true)
    }
    
    public func shrinkButton() {
        self.shapeLayer?.removeFromSuperlayer()
        self.bPath?.removeAllPoints()
        self.angle = 0;
        self.shapeTimer?.invalidate()
        self.shapeTimer = nil
        if (self.innerCircle == nil){
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.innerCircle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.circleBorder.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            self.circleBorder.borderWidth = 6.0
        }, completion: { (success) in
            self.innerCircle.removeFromSuperview()
            //self.innerCircle = nil
        })
    }
    
    @objc fileprivate func drawShape() {
        shapeLayer?.removeFromSuperlayer()
        bPath?.removeAllPoints()
        if  Int(angle!) < 360
        {
            angle = angle!+annulusTime!/5
            initLayout()
        }
        else{}
    }
    func initLayout() -> Void {
        shapeLayer = CAShapeLayer()
        shapeLayer?.strokeColor = annulusColor?.cgColor
        shapeLayer?.fillColor = UIColor.clear.cgColor
        shapeLayer?.frame = self.bounds;
        shapeLayer?.lineWidth = 15
        layer.insertSublayer(shapeLayer!, at: UInt32(self.subviews.count))
        bPath = UIBezierPath(arcCenter: CGPoint(x:self.bounds.width/2,y:self.bounds.width/2), radius: self.bounds.width/2, startAngle: CGFloat(Double.pi)*0, endAngle: CGFloat(angle!*Double.pi/180), clockwise: true)
        shapeLayer?.path = bPath?.cgPath;
    }
    
}

