/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit
import GameplayKit

class GameOverState: GKState {
  unowned let scene: GameScene

  let hitGroundAction = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
  let animationDelay = 0.3

  init(scene: SKScene) {
    self.scene = scene as! GameScene
    super.init()
  }

  override func didEnter(from previousState: GKState?) {
    scene.run(hitGroundAction)
    scene.stopSpawning()
    scene.player.movementAllowed = false
    showScoreCard()
  }

  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is PlayingState.Type
  }

  override func update(deltaTime seconds: TimeInterval) {

  }

  func setBestScore(_ bestScore: Int) {
    UserDefaults.standard.set(bestScore, forKey: "BestScore")
    UserDefaults.standard.synchronize()
  }

  func getBestScore() -> Int { // <-- renamed this function to make things clearer.
    return UserDefaults.standard.integer(forKey: "BestScore")
  }

  func showScoreCard() {
    if scene.score > getBestScore() {
      setBestScore(scene.score)
    }

    let scorecard = SKSpriteNode(imageNamed: "ScoreCard")
    scorecard.position = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.5)
    scorecard.name = "Tutorial"
    scorecard.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(scorecard)

    let lastScore = SKLabelNode(fontNamed: scene.fontName)
    lastScore.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    lastScore.position = CGPoint(x: -scorecard.size.width * 0.25, y: -scorecard.size.height * 0.2)
    lastScore.zPosition = Layer.ui.rawValue
    lastScore.text = "\(scene.score / 2)"
    scorecard.addChild(lastScore)

    let bestScore = SKLabelNode(fontNamed: scene.fontName)
    bestScore.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    bestScore.position = CGPoint(x: scorecard.size.width * 0.25, y: -scorecard.size.height * 0.2)
    bestScore.zPosition = Layer.ui.rawValue
    bestScore.text = "\(getBestScore() / 2)"
    scorecard.addChild(bestScore)

    let gameOver = SKSpriteNode(imageNamed: "GameOver")
    gameOver.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 + scorecard.size.height / 2 + scene.margin + gameOver.size.height / 2)
    gameOver.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(gameOver)

    let okButton  = SKSpriteNode(imageNamed: "Button")
    okButton.position = CGPoint(x: scene.size.width * 0.25, y: scene.size.height / 2 - scorecard.size.height / 2 - scene.margin - okButton.size.height / 2)
    okButton.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(okButton)

    let okText = SKSpriteNode(imageNamed: "OK")
    okText.position = CGPoint.zero
    okText.zPosition = Layer.ui.rawValue
    okButton.addChild(okText)

    let shareButton  = SKSpriteNode(imageNamed: "Button")
    shareButton.position = CGPoint(x: scene.size.width * 0.75, y: scene.size.height / 2 - scorecard.size.height / 2 - scene.margin - shareButton.size.height / 2)
    shareButton.zPosition = Layer.ui.rawValue
    scene.worldNode.addChild(shareButton)

    let shareText = SKSpriteNode(imageNamed: "Share")
    shareText.position = CGPoint.zero
    shareText.zPosition = Layer.ui.rawValue
    shareButton.addChild(shareText)

    // Juice
    gameOver.setScale(0)
    gameOver.alpha = 0
    let group = SKAction.group([
      SKAction.fadeIn(withDuration: animationDelay),
      SKAction.scale(to: 1.0, duration: animationDelay)
      ])
    group.timingMode = .easeInEaseOut
    gameOver.run(SKAction.sequence([
      SKAction.wait(forDuration: animationDelay),
      group
      ]))

    scorecard.position = CGPoint(x: scene.size.width * 0.5, y: -scorecard.size.height / 2)
    let moveTo = SKAction.move(to: CGPoint(x: scene.size.width / 2, y: scene.size.height / 2), duration: animationDelay)
    moveTo.timingMode = .easeInEaseOut
    scorecard.run(SKAction.sequence([
      SKAction.wait(forDuration: animationDelay * 2),
      moveTo
      ]))

    okButton.alpha = 0
    shareButton.alpha = 0
    let fadeIn = SKAction.sequence([
      SKAction.wait(forDuration: animationDelay * 3),
      SKAction.fadeIn(withDuration: animationDelay)
      ])
    okButton.run(fadeIn)
    shareButton.run(fadeIn)

    let pops = SKAction.sequence([
      SKAction.wait(forDuration: animationDelay),
      scene.popAction,
      SKAction.wait(forDuration: animationDelay),
      scene.popAction,
      SKAction.wait(forDuration: animationDelay),
      scene.popAction,
      ])
    scene.run(pops)
  }
}
