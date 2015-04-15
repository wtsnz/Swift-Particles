//
//  ViewController.swift
//  Particles
//
//  Created by William Townsend on 15/04/15.
//  Copyright (c) 2015 William Townsend. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let particleField = ParticleField(frame: self.view.bounds)
        self.view.addSubview(particleField)
    }

}

class ParticleField: UIView {
    
    // MARK: Properties
    
    var displayLink: CADisplayLink?
    
    var array:[Particle] = [Particle]()
    
    let colors = [UIColor(rgba: "#69D2E7"), UIColor(rgba: "#A7DBD8"), UIColor(rgba: "#E0E4CC"), UIColor(rgba: "#F38630"), UIColor(rgba: "#FA6900"), UIColor(rgba: "#FF4E50"), UIColor(rgba: "#F9D423")]
    
    // MARK: Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.multipleTouchEnabled = true

        
        self.displayLink = CADisplayLink(target: self, selector: Selector("onFrame"))
        self.displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.create()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIResponder
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        for touch in touches as! Set<UITouch> {
            self.spawnForTouch(touch)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        for touch in touches as! Set<UITouch> {
            self.spawnForTouch(touch)
        }
    }
    
    // MARK: View
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var context = UIGraphicsGetCurrentContext();
        
        CGContextClearRect(context, self.bounds);
        
        CGContextSetBlendMode(context, kCGBlendModeLighten);
        
        for (index, particle) in enumerate(self.array) {
            
            particle.draw(context)
            
        }
    }
    
    // MARK: Functions
    
    func create() {
        for i in 0...200 {
            let x = CGFloat(arc4random_uniform(UInt32(self.frame.width)))
            let y = CGFloat(arc4random_uniform(UInt32(self.frame.height)))
            self.spawn(x, y: y)
        }
    }
    
    func onFrame() {
        
        for var i = self.array.count - 1; i >= 0; i-- {
            var particle = self.array[i]
            if particle.alive {
                particle.move()
            } else {
                array.removeAtIndex(i)
            }
        }
        self.setNeedsDisplay()
    }
    
    func spawnForTouch(touch: UITouch) {
        self.spawn(touch.locationInView(self).x, y: touch.locationInView(self).y)
        self.spawn(touch.locationInView(self).x, y: touch.locationInView(self).y)
        self.spawn(touch.locationInView(self).x, y: touch.locationInView(self).y)
        self.spawn(touch.locationInView(self).x, y: touch.locationInView(self).y)
    }
    
    func spawn(x: CGFloat, y: CGFloat) {
        
        let force = random(-8.0, 8.0)
        var particle = Particle(x: x, y: y, radius: random(10, 20))
        
        particle.wander = random(0, 5.3)
        particle.drag = random(0.9, 0.99)
        particle.theta = random(0.0, CGFloat(M_PI_2))
        particle.vx = sin(particle.theta) * force
        particle.vy = cos(particle.theta) * force
        particle.fillColor = self.colors[Int(arc4random_uniform(UInt32(self.colors.count)))]
        
        self.array.append(particle)
    }
}

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max:CGFloat) -> CGFloat {
    return random()*(max-min)+min
}

class Particle {
    
    var x: CGFloat
    var y: CGFloat
    
    var vx: CGFloat = 0
    var vy: CGFloat = 0
    
    var radius: CGFloat = 20
    var alive = true
    var wander = CGFloat(1.15)
    var theta = random(0, 2*3.14159265)
    var drag = CGFloat(0.92)
    
    
    var fillColor: UIColor = UIColor.redColor()
    
    init(x:CGFloat, y: CGFloat, radius: CGFloat) {
        self.x = x
        self.y = y
        self.radius = radius
    }

    func move() {
        
        self.x += self.vx
        self.y += self.vy
        
        self.vx *= self.drag
        self.vy *= self.drag
        
        self.theta += random(-0.5, 0.5) * self.wander
        
        self.vx += sin(self.theta) * 0.1
        self.vy += cos(self.theta) * 0.1
        
        self.radius *= 0.96
        
        self.alive = self.radius > 0.1
    }
    
    func draw(ctx: CGContextRef) {
        
        var frame = CGRectMake(self.x - self.radius, self.y - self.radius, radius*2, radius*2)
        
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor)
        CGContextFillEllipseInRect(ctx, frame)
        
    }
}

