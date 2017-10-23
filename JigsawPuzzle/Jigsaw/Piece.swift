//
//  Piece.swift
//  JigsawPuzzle
//
//  Created by Arturs Derkintis on 23/10/2017.
//  Copyright © 2017 Starfly. All rights reserved.
//

import SpriteKit

class Piece: SKSpriteNode {

    var correctPosition : CGPoint?
    var con : ConectionTags?
    var sprite : SKSpriteNode?
    var tapTimeInterval : Int = 0
    var taps = 0
    let rotationTimeLimit = 3
    var counterTimer : Timer?
    var rotation = PieceRotation.zero
    var tag : Int?
    var hasMoved = false

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = false
        con = ConectionTags()
    }
    func rotateRandomly(){
        let array = [0, 90, 180, 270]
        let index = randomInRange(0, upper: array.count - 1)
        rotation = PieceRotation(rawValue: index)!
        let randomRot = array[index].degreesToRadians
        let action = SKAction.rotate(byAngle: randomRot, duration: 1.5)
        run(action)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func touchStart(){
        counterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Piece.addMiliSec), userInfo: nil, repeats: true)
    }

    func touchMoves(_ point : CGPoint){
        hasMoved = true
        let action = SKAction.move(to: point, duration: 0.001)
        run(action)
    }

    func touchEnd(){
        counterTimer?.invalidate()
        counterTimer = nil
        if hasMoved == false{
            if tapTimeInterval <= 3{
                let action = SKAction.rotate(byAngle: 90.degreesToRadians, duration: 0.2)
                run(action)
                tapTimeInterval = 0
                if taps < 3{
                    taps += 1
                    rotation = PieceRotation(rawValue: taps)!

                }else{
                    rotation = .zero
                    taps = 0
                }
            }}
        tapTimeInterval = 0
        hasMoved = false
    }
    
    func addMiliSec(){
        tapTimeInterval += 1
    }


}
