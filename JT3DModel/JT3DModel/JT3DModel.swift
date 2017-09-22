//
//  JT3DModel.swift
//  JT3DModel
//
//  Created by 谭振杰 on 2017/9/21.
//  Copyright © 2017年 谭振杰. All rights reserved.
//

import UIKit
import Darwin
import GLKit

class JT3DModel: UIView {
    // 边长
    var _side: Float?
    var side: Float {
        get {
            return _side!
        }
        set {
            _side = newValue
            
            // 正
            self.addCubeLayer(params: [0, 0, newValue / 2, 0, 0, 0, 0])
            // 背
            self.addCubeLayer(params: [0, 0, -newValue / 2, Float.pi, 0, 0, 0])
            // 左
            self.addCubeLayer(params: [-newValue / 2, 0, 0, -Float.pi / 2, 0, 1, 0])
            // 右
            self.addCubeLayer(params: [newValue / 2, 0, 0, Float.pi / 2, 0, 1, 0])
            // 上
            self.addCubeLayer(params: [0, -newValue / 2, 0, -Float.pi / 2, 1, 0, 0])
            // 下
            self.addCubeLayer(params: [0, newValue / 2, 0, Float.pi / 2, 1, 0, 0])
            
            var transform3D = CATransform3DIdentity
            transform3D.m34 = -1.0 / 2_000
            _cubeLayer.sublayerTransform = transform3D
            
            self.layer.addSublayer(_cubeLayer)
        }
    }
    
    // 是否自动旋转
    var _autoAnimate: Bool?
    var autoAnimate: Bool {
        get {
            return _autoAnimate!
        }
        set {
            _autoAnimate = newValue
            
            if newValue == true {
                self.addAnimation()
            } else {
                self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action:#selector(panRotate(ges:))))
            }
        }
    }
    
    
    lazy var _cubeLayer = CALayer()
    var _rotMatrix: GLKMatrix4?
    var start: CGPoint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _cubeLayer.frame = self.bounds
        _cubeLayer.contentsScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func cube3D(with frame: CGRect, side: Float, autoAnimate: Bool) -> JT3DModel {
        let cube3D = JT3DModel(frame: frame)
        cube3D.side = side
        cube3D.autoAnimate = autoAnimate
        
        return cube3D
    }
}

// MARK: - 事件处理
extension JT3DModel {
    
    func panRotate(ges: UIPanGestureRecognizer) {
        if ges.state == .began {
            start = ges.location(in: self)
        } else if ges.state == .changed {
            let transform = _cubeLayer.sublayerTransform
            _rotMatrix = JT3DModel.CATransform3DToGLKMatrix4(transform: transform)
            
            let loc = ges.location(in: self)
            let diff = CGPoint(x: (start?.x)! - loc.x, y: (start?.y)! - loc.y)
            
            let rotX = 1 * GLKMathDegreesToRadians(Float(diff.y / 2.0))
            let rotY = -1 * GLKMathDegreesToRadians(Float(diff.x / 2.0))
            
            var isInvertible: Bool = false
            let xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix!, &isInvertible), GLKVector3Make(1, 0, 0))
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix!, rotX, xAxis.x, xAxis.y, xAxis.z)
            let yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix!, &isInvertible), GLKVector3Make(0, 1, 0))
            _rotMatrix = GLKMatrix4Rotate(_rotMatrix!, rotY, yAxis.x, yAxis.y, yAxis.z)
            
            _cubeLayer.sublayerTransform = JT3DModel.GLKMatrix4ToCATransform3D(matrix4: _rotMatrix!)
            
            start = loc
        }
    }
}

// MAKR: - 转换方法
extension JT3DModel {
    static func CATransform3DToGLKMatrix4(transform: CATransform3D) -> GLKMatrix4 {
        return GLKMatrix4Make(Float(transform.m11), Float(transform.m12), Float(transform.m13), Float(transform.m14), Float(transform.m21), Float(transform.m22), Float(transform.m23), Float(transform.m24), Float(transform.m31), Float(transform.m32), Float(transform.m33), Float(transform.m34), Float(transform.m41), Float(transform.m42), Float(transform.m43), Float(transform.m44))
    }
    
    static func GLKMatrix4ToCATransform3D(matrix4: GLKMatrix4) -> CATransform3D {
        return CATransform3D.init(m11: CGFloat(matrix4.m00), m12: CGFloat(matrix4.m01), m13: CGFloat(matrix4.m02), m14: CGFloat(matrix4.m03), m21: CGFloat(matrix4.m10), m22: CGFloat(matrix4.m11), m23: CGFloat(matrix4.m12), m24: CGFloat(matrix4.m13), m31: CGFloat(matrix4.m20), m32: CGFloat(matrix4.m21), m33: CGFloat(matrix4.m22), m34: CGFloat(matrix4.m23), m41: CGFloat(matrix4.m30), m42: CGFloat(matrix4.m31), m43: CGFloat(matrix4.m32), m44: CGFloat(matrix4.m33))
    }
}

// MARK: - 内部方法
extension JT3DModel {
    
    func addCubeLayer(params: [Float]) {
        let gradient = CAGradientLayer()
        gradient.contentsScale = UIScreen.main.scale
        gradient.bounds = CGRect(x: 0.0, y: 0.0, width: Double(side), height: Double(side))
        gradient.position = self.center
        gradient.colors = [UIColor.gray.cgColor, UIColor.black.cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        // 抗锯齿
        gradient.shouldRasterize = true
        
        let trans3D = CATransform3DMakeTranslation(CGFloat(params[0]), CGFloat(params[1]), CGFloat(params[2]))
        let rotate3D = CATransform3DRotate(trans3D, CGFloat(params[3]), CGFloat(params[4]), CGFloat(params[5]), CGFloat(params[6]))
        let transform3D = rotate3D
        
        
        gradient.transform = transform3D
        
        _cubeLayer.addSublayer(gradient)
    }
    
    func addAnimation() {
        _cubeLayer.sublayerTransform = CATransform3DRotate(_cubeLayer.sublayerTransform, CGFloat(Float.pi / 9.0), 0.5, 0.5, 0.5)
        let animation = CABasicAnimation.init(keyPath: "sublayerTransform.rotation.y")
        animation.toValue = MAXFLOAT
        animation.duration = CFTimeInterval(MAXFLOAT)
        _cubeLayer.add(animation, forKey: "rotation")
    }
}
