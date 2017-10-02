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
    var imageTiles = ([UIImage](), [CGPoint]())
    var guidePhoto : SKSpriteNode?
    var movingPiece : Piece?
    var maxZPosition : CGFloat = Layer.Tiles
    override func didMove(to view: SKView) {
        super.didMove(to: view)
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
        //button.setImageForState(UIImage(named: "menu")!, state: SKButtonState.Normal)
        //button.setImageForState(UIImage(named: "menu_clicked")!, state: SKButtonState.Highlighted)
        button.addTarget(self, selector: #selector(JigsawPuzzle.tapped), event: SKButtonEvent.touchUpInside)
        addChild(button)
    }
    func tapped(){
        border?.removeAllChildren()
        startNewPuzzleGameLevel()
    }

    
    func startNewPuzzleGameLevel(){
        border?.removeAllChildren()
        let tilesInLine = 9
        pieces.removeAll()
        piecesCount = tilesInLine * tilesInLine
        if imageTiles.0.count == 0{
            let image = UIImage(named: "car")!
            
            imageTiles = image.jigSawCuter(CGSize(width: 760, height: 698), piecesCount: piecesCount!)
        }

        for i in 0...80{
            setPiece(CGSize(width: width, height: width), index : i)
            
        }
        guidePhoto = SKSpriteNode(imageNamed: "car")
        guidePhoto?.size = CGSize(width: 760, height: 698)
        guidePhoto?.zPosition = Layer.GuidePhoto
        guidePhoto?.anchorPoint = CGPoint(x: 0, y: 0)
        guidePhoto?.position = CGPoint(x: 0, y: 0)
        guidePhoto?.alpha = 0.01
        border!.addChild(guidePhoto!)
        
        
        for piece in pieces{
            setNeighboursInSafeDistance(piece)
        }
        
        delay(3) { () -> () in
           self.smashAndCrashDown()
        }
        
        
        
    }
   

    func smashAndCrashDown(){
        
//        let fallRect1 = CGRectMake(50, 50, frame.width - 100, 5)                   //down rect (unused)
//        let fallRect2 = CGRectMake(50, frame.height - 130, frame.width - 100, 5)   //up rect (unused)
        let fallRect3 = CGRect(x: 55, y: 50, width: 5, height: frame.height - 110)                  //left rect
        let fallRect4 = CGRect(x: frame.width - 65, y: 50, width: 5, height: frame.height - 110)   //right rect
        let rects = [fallRect3, fallRect4]
        for piece in pieces{
            let rect = rects[randomInRange(0, upper: rects.count - 1)]
            let point = CGPoint.randomPointInRect(rect)
            let position = convert(point, to: border!)
            let action = SKAction.move(to: position, duration: 1.5)
            piece.run(action)
            piece.rotateRandomly()
        }
        let fadein = SKAction.fadeAlpha(to: 0.3, duration: 1.5)
        guidePhoto?.run(fadein)
    }
    func setPiece(_ size : CGSize, index : Int){
        let piece = Piece()
        piece.anchorPoint  = CGPoint(x: 0.5, y: 0.5)
        piece.size = size
        piece.color = UIColor.blue
        piece.name = pieceName
        pieces.append(piece)
        piece.tag = index
        let texture = SKTexture(image: imageTiles.0[index])
        let point = imageTiles.1[index]
        piece.zPosition = CGFloat(index + 10)
        maxZPosition = CGFloat(index + 10)
        piece.texture = texture
        piece.size = texture.size()
        let conP = convertUIPointToSprite(point, node: border!)
        piece.position = conP
        points.append(conP)
        piece.correctPosition = conP
        border?.addChild(piece)
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
        
        for touch in touches{
            let loc = touch.location(in: border!)
            let nodes = border!.nodes(at: loc)
            var piecess = [Piece]()
            for node in nodes where node.name == pieceName{
                if node.isKind(of: Piece.self) {
                    piecess.append((node as? Piece)!)
                }
                
            }
            var minElem = CGFloat.leastNormalMagnitude
            var index : Int = 0
            for piece in piecess{
                if piece.zPosition > minElem{
                    minElem += piece.zPosition
                    index = piecess.index(of: piece)!
                }
            }
            if piecess.count > 0{
                maxZPosition += 1
                movingPiece = piecess[index] as Piece
                movingPiece?.zPosition = maxZPosition
                movingPiece?.touchStart()
            }
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let loc = touch.location(in: border!)
            movingPiece?.touchMoves(loc)
        }

    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            movingPiece?.touchEnd()
        if let node = movingPiece{
            radar(node)}
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
                index = distances.index(of: distance)!
            }
        }
        let point = points[index]
        if piece.correctPosition == point{
        let action = SKAction.move(to: point, duration: 0.2)
            piece.run(action)
        }
    }
    func setNeighboursInSafeDistance(_ piece : Piece){
        ///This method has no impact to anything, its there bcs I can!
        let widthe = piece.size.width * 0.9
        let centerNodePosition = piece.position
        let upPoint = CGPoint(x: centerNodePosition.x, y: centerNodePosition.y + widthe)
        let rightPoint = CGPoint(x: centerNodePosition.x + widthe, y: centerNodePosition.y)
        let leftPoint = CGPoint(x: centerNodePosition.x - widthe, y: centerNodePosition.y)
        let downPoint = CGPoint(x: centerNodePosition.x, y: centerNodePosition.y - widthe)
        let upNodes = border?.nodes(at: upPoint)
        let rightNodes = border?.nodes(at: rightPoint)
        let leftNodes  = border?.nodes(at: leftPoint)
        let downNodes = border?.nodes(at: downPoint)
        if let up = upNodes{
        for pie in up where pie.name == pieceName{
            piece.con!.top = (pie as! Piece).tag!
            }
        }
        if let right = rightNodes{
            for pie in right where pie.name == pieceName{
                piece.con!.right = (pie as! Piece).tag!
            }
        }
        if let left = leftNodes{
            for pie in left where pie.name == pieceName{
                piece.con!.left = (pie as! Piece).tag!
            }
        }
        if let down = downNodes{
            for pie in down where pie.name == pieceName{
                let tag = (pie as! Piece).tag!
                piece.con!.bottom = tag
            }
        }
    }
}

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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
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
