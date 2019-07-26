//
//  GameScene.swift
//  IK1
//
//  Created by Chuck Deerinck on 7/25/19.
//  Copyright © 2019 Chuck Deerinck. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {

    var shoulder = SKShapeNode()
    var endEffector = SKShapeNode()

    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 1.5),
                                                SKAction.fadeOut(withDuration: 1.5)])
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        return sequence
    }()

    override func didMove(to view: SKView) {

        self.anchorPoint=CGPoint(x: 0.5,y: 0.5)
        self.scaleMode = .resizeFill //.aspectFit
        //self.setScale(1.0)

        let sectionLength: CGFloat = 100
        let sectionRect = CGRect(x: -10, y: -sectionLength,
                                 width: 20, height: sectionLength)

        let upperArm = SKShapeNode(rect: sectionRect)
        let midArm = SKShapeNode(rect: sectionRect)
        let lowerArm = SKShapeNode(rect: sectionRect)
         shoulder = SKShapeNode(circleOfRadius: 5)
        let elbow = SKShapeNode(circleOfRadius: 5)
        let wrist = SKShapeNode(circleOfRadius: 5)
         endEffector = SKShapeNode(circleOfRadius: 5)

        shoulder.strokeColor = .red
        elbow.strokeColor = .green
        wrist.strokeColor = .cyan
        self.addChild(shoulder)
        shoulder.addChild(upperArm)
        upperArm.addChild(elbow)
        elbow.addChild(midArm)
        midArm.addChild(wrist)
        wrist.addChild(lowerArm)
        lowerArm.addChild(endEffector)

        shoulder.constraints = [SKConstraint.positionX(SKRange(constantValue: 0),
                                                       y: SKRange(constantValue: 0))]

        let positionConstraint = SKConstraint.positionY(SKRange(constantValue: -sectionLength))
        let pivotConstraint = SKReachConstraints(lowerAngleLimit: -CGFloat.pi/4, upperAngleLimit: CGFloat.pi/4)

        elbow.constraints =  [ positionConstraint ]
        elbow.reachConstraints = pivotConstraint
        midArm.reachConstraints = pivotConstraint
        wrist.constraints = [ positionConstraint]
        wrist.reachConstraints = pivotConstraint
        lowerArm.reachConstraints = pivotConstraint
        endEffector.constraints = [ positionConstraint ]

        for _ in (0...20) {
            let node = SKShapeNode(circleOfRadius: 5)
            node.name = "bomb"
            node.fillColor = .red
            node.position = CGPoint(x: CGFloat.random(in: -250...250),y: CGFloat.random(in: -250...250))
            scene?.addChild(node)
        }

    }

    func touchDown(atPoint pos : CGPoint) {
        let reachAction = SKAction.reach(to: pos,
                                         rootNode: shoulder,
                                         duration: 1.0)

        endEffector.run(reachAction)
        print(pos)
    }

    func touchMoved(toPoint pos : CGPoint) {
        print(pos)
    }

    func touchUp(atPoint pos : CGPoint) {
        print(pos)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func update(_ currentTime: TimeInterval) {

    }
}
