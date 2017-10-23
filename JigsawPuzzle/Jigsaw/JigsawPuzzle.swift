//
//  JigsawPuzzle.swift
//  puzzleGame
//
//  Created by Arturs Derkintis on 8/16/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import SpriteKit

class JigsawPuzzle: SKScene {
    var border : SKSpriteNode?
    var points = [CGPoint]()
    var pieces = [Piece]()
    var piecesCount : Int?
    var width : CGFloat = 0
    var imageTiles: ([UIImage], [CGPoint])?
    var guidePhoto : SKSpriteNode?
    var movingPiece : Piece?
    var maxZPosition : CGFloat = Layer.Tiles
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        anchorPoint = .zero
        backgroundColor = UIColor.lightGray
        setBorder()
        startNewPuzzleGameLevel()
        restartButton()

    }
    func restartButton(){
        
        let button = SKButton(color: .red, size: .zero)
        button.animatable = true
        button.size = CGSize(width: 100, height: 50)
        button.anchorPoint = CGPoint(x: 0, y: 0)
        button.position = CGPoint(x: 5, y: frame.height - 55)
        button.zPosition = 101
        button.setTitle("Restart")
        button.addTarget(self, selector: #selector(JigsawPuzzle.restart), event: SKButtonEvent.touchUpInside)
        addChild(button)
    }
    func restart() {
        border?.removeAllChildren()
        startNewPuzzleGameLevel()
    }

    
    func startNewPuzzleGameLevel(){
        border?.removeAllChildren()
        pieces.removeAll()
        guard let image = UIImage(named: "car"),
                let border = border else {
            return
        }

        imageTiles = image.jigSawCuter(CGSize(width: 760, height: 698))

        for i in 0..<(imageTiles?.0.count ?? 0) {
            setPiece(CGSize(width: width, height: width), index : i)
        }

        imageTiles = nil
        guidePhoto = SKSpriteNode(imageNamed: "car")
        guidePhoto?.size = CGSize(width: 760, height: 698)
        guidePhoto?.zPosition = Layer.GuidePhoto
        guidePhoto?.anchorPoint = CGPoint(x: 0, y: 0)
        guidePhoto?.position = CGPoint(x: 0, y: 0)
        guidePhoto?.alpha = 0.01
        guard let guidePhoto = guidePhoto else { return }
        border.addChild(guidePhoto)
        
        delay(3) { () -> () in
            self.smashAndCrashDown()
        }
        
        
        
    }

    func smashAndCrashDown(){
        guard let border = border else { return }
        let fallRect3 = CGRect(x: 55, y: 50, width: 5, height: frame.height - 110)                  //left rect
        let fallRect4 = CGRect(x: frame.width - 65, y: 50, width: 5, height: frame.height - 110)
        //right rect
        let rects = [fallRect3, fallRect4]
        for piece in pieces{
            let rect = rects[randomInRange(0, upper: rects.count - 1)]
            let point = CGPoint.randomPointInRect(rect)
            let position = convert(point, to: border)
            let action = SKAction.move(to: position, duration: 1.5)
            piece.run(action)
            piece.rotateRandomly()
        }
        let fadein = SKAction.fadeAlpha(to: 0.3, duration: 1.5)
        guidePhoto?.run(fadein)
    }

    func setPiece(_ size : CGSize, index : Int){
        guard let image = imageTiles?.0[index],
            let center = imageTiles?.1[index],
            let border = border else {
                return
        }
        let piece = Piece()
        piece.anchorPoint  = CGPoint(x: 0.5, y: 0.5)
        piece.size = size
        piece.color = UIColor.blue
        piece.name = pieceName
        pieces.append(piece)
        piece.tag = index

        let texture = SKTexture(image: image)
        piece.zPosition = CGFloat(index + 10)
        maxZPosition = CGFloat(index + 10)
        piece.texture = texture
        piece.size = texture.size()
        let conP = convertUIPointToSprite(center, node: border)
        piece.position = conP
        points.append(conP)
        piece.correctPosition = conP
        border.addChild(piece)
    }
    
    func setBorder(){
        let sprite = SKSpriteNode()
        
        sprite.color = .clear
        sprite.size = CGSize(width: 760, height: 698)
        sprite.position = CGPoint(x: (frame.width - 760) * 0.5, y: 30)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        

        addChild(sprite)
        border = sprite
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let border = border else { return }
        for touch in touches{
            let loc = touch.location(in: border)
            let nodes = border.nodes(at: loc)
            var pieces: [Piece] = []
            for node in nodes where node.name == pieceName{
                if let piece = node as? Piece {
                    pieces.append(piece)
                }
                
            }
            var minElem = CGFloat.leastNormalMagnitude
            var index : Int = 0
            for piece in pieces{
                if piece.zPosition > minElem{
                    minElem += piece.zPosition
                    index = pieces.index(of: piece)!
                }
            }
            if pieces.count > 0{
                maxZPosition += 1
                movingPiece = pieces[index] as Piece
                movingPiece?.zPosition = maxZPosition
                movingPiece?.touchStart()
            }
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let border = border else { return }
        for touch in touches{
            let loc = touch.location(in: border)
            movingPiece?.touchMoves(loc)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingPiece?.touchEnd()
        if let node = movingPiece{
            radar(node)
        }
    }
    
    func radar(_ piece : Piece){
        let position = piece.position
        var distances = [CGFloat]()
        for point in points{
            let distance = distanceBetweenPoints(point, point2: position)
            distances.append(distance)
        }
        var min = CGFloat.greatestFiniteMagnitude
        var index = 0
        for distance in distances{
            if distance < min{
                min = distance
                index = distances.index(of: distance) ?? 0
            }
        }

        let point = points[index]
        if piece.correctPosition == point{
            let action = SKAction.move(to: point, duration: 0.2)
            piece.run(action)
        }
    }

}


