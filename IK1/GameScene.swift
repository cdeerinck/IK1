//
//  GameScene.swift
//  IK1
//
//  Created by Chuck Deerinck on 7/25/19.
//  Copyright © 2019 Chuck Deerinck. All rights reserved.
//

import Foundation
import SpriteKit

let shockSpeed = 3.5
let armSpeed = 2.5

class GameScene: SKScene, SKPhysicsContactDelegate {

    var shoulder = SKShapeNode()
    var endEffector = SKShapeNode()
    var armIsBusy = false
    var frameCount = 0
    var bombDeficit = 100


    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: shockSpeed),
                                                SKAction.fadeOut(withDuration: shockSpeed)])
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        return sequence
    }()

    func makeBomb() {
        let node = SKShapeNode(circleOfRadius: 5)
        node.name = "bomb"
        node.fillColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        node.position = CGPoint(x: CGFloat.random(in: -250...250),y: CGFloat.random(in: -250...250))
        node.physicsBody = SKPhysicsBody(circleOfRadius: 5.0)
        //node.physicsBody?.collisionBitMask = 0xFFFFFFFF
        node.physicsBody?.contactTestBitMask = 0xFFFFFFFF
        //node.physicsBody?.categoryBitMask = 0x2
        scene?.addChild(node)
    }


    override func didMove(to view: SKView) {

        self.anchorPoint=CGPoint(x: 0.5,y: 0.5)
        self.scaleMode = .resizeFill //.aspectFit
        //self.setScale(1.0)
        scene?.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        scene?.physicsWorld.contactDelegate = self
        scene?.view?.showsPhysics = true
        scene?.view?.showsFields = true

        let sectionLength: CGFloat = 150
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
        let frozenConstraint = SKConstraint.positionX(SKRange(constantValue: 0))
        let pivotConstraint = SKReachConstraints(lowerAngleLimit: -CGFloat.pi/3, upperAngleLimit: CGFloat.pi/3)

        elbow.constraints =  [ positionConstraint ]
        elbow.reachConstraints = pivotConstraint
        midArm.reachConstraints = pivotConstraint
        wrist.constraints = [ positionConstraint]
        wrist.reachConstraints = pivotConstraint
        lowerArm.reachConstraints = pivotConstraint
        endEffector.constraints = [ positionConstraint, frozenConstraint ]
        endEffector.name = "hand"
        endEffector.physicsBody = SKPhysicsBody(circleOfRadius: 5.0)
        //endEffector.physicsBody?.collisionBitMask = 0xFFFFFFFF
        endEffector.physicsBody?.contactTestBitMask = 0xFFFFFFFF
        //endEffector.physicsBody?.categoryBitMask = 0x1


       bombDeficit = 100

    }

    func collisionBetween(obj1: SKNode, obj2: SKNode) {
        print("Collision \(obj1.name ?? "") hit \(obj2.name ?? ""))")
    }

    func blowUp(_ bomb:SKNode) {
        let shockwave = SKShapeNode(circleOfRadius: 1)
        if let shapeNode = bomb as? SKShapeNode {
            shockwave.strokeColor = shapeNode.fillColor //.magenta
        }
        shockwave.position = bomb.position
        shockwave.zPosition = 1

        shockwave.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        shockwave.physicsBody?.collisionBitMask = 0x0
        shockwave.name = "shockwave"
        scene!.addChild(shockwave)
        shockwave.run(shockWaveAction)
        bomb.removeFromParent()
    }

    func didBegin(_ contact: SKPhysicsContact) { //checking for contact
        print("Contact \(contact.bodyA.node?.name ?? "") hit \(contact.bodyB.node?.name ?? "") ")
        if contact.bodyA.node?.name == "bomb" { blowUp(contact.bodyA.node!) }
        if contact.bodyB.node?.name == "bomb" { blowUp(contact.bodyB.node!) }
    }

    func idleArm(at: CGPoint) {
        if !armIsBusy {
            let reachAction = SKAction.reach(to: at,
                                             rootNode: shoulder,
                                             duration: armSpeed)

            armIsBusy = true
            endEffector.run(reachAction, completion: { self.armIsBusy = false })
        }
    }

    func touchDown(atPoint pos : CGPoint) {
        idleArm(at: pos)
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
        if let randomBomb = scene?.children.filter({$0.name=="bomb"}).randomElement() {
            idleArm(at:randomBomb.position)
        } else {
            bombDeficit = 100
        }
        frameCount += 1
        if frameCount%400 == 0 {
            bombDeficit += 1
        }
        if bombDeficit > 0 {
            makeBomb()
            bombDeficit -= 1
        }
    }
}
