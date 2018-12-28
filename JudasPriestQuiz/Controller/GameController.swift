//
//  GameController.swift
//  JudasPriestQuiz
//
//  Created by Cat on 10/5/18.
//  Copyright © 2018 Cat. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore

class GameController: UIViewController {
  @IBOutlet weak var button1: UIButton!
  @IBOutlet weak var button2: UIButton!
  @IBOutlet weak var button3: UIButton!
  @IBOutlet weak var button4: UIButton!
  @IBOutlet weak var albumImage: UIImageView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var questionLabel: UILabel!
  
  private var buttonsArray:  [UIButton] = []
  private var pictures:      [String]   = []
  private var answers:       [String]   = []
  private var uniqueAnswers: [String]   = []
  private var currentAnswer: String     = ""
  
  private var auidioPlayer = AVAudioPlayer()
  
  private var score = 0 { didSet { scoreLabel.text = String(describing: score) } }
  private var round = 0 { didSet { questionLabel.text = "Question \(round) of \(18)" } }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    buttonsArray = [button1, button2, button3, button4]
    
    startAudio()
    fillPictures()
    startGame()
  }
  
  private func startAudio() {
    do {
      auidioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "BreakingTheLaw", ofType: "mp3")!))
      auidioPlayer.prepareToPlay()
    }
    catch {
      print(error)
    }
  }
  
  private func startGame() {
    let transition = CATransition()
    transition.type = CATransitionType.fade
    transition.duration = 1
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.layer.add(transition, forKey: nil)
    
    auidioPlayer.stop()
    questionLabel.text = "Question \(round) of \(pictures.count)"
    setQuestion()
  }
  
  private func fillPictures() {
    let fileManager = FileManager.default
    let path = Bundle.main.resourcePath!
    let items = try! fileManager.contentsOfDirectory(atPath: path)
    
    for item in items where item.hasPrefix("quiz_") { pictures.append(item) }
    answers = pictures
    uniqueAnswers = pictures
  }
  
  private func processName(name: String) -> String {
    return name.replacingOccurrences(of: "quiz_", with: "").replacingOccurrences(of: ".png", with: "")
  }
  
}

extension GameController {
  
  @IBAction func tapAnswer(_ sender: UIButton) {
    if buttonsArray[sender.tag].titleLabel?.text == currentAnswer {
      correctAnswer()
    }
    setQuestion()
  }
  
  private func setQuestion() {
    round += 1
    
    if round < 19 {
      guard let element = pictures.randomElement() else { return }
      albumImage.image = UIImage.init(named: element)
      currentAnswer = processName(name: element)
      
      var buttons = buttonsArray
      let randomIndex = getRandomIndex(array: buttons)
      buttons[randomIndex].setTitle(currentAnswer, for: .normal)
      buttons.remove(at: randomIndex)
      
      if pictures.contains(element) {
        pictures.removeAll { $0 == element }
      }
      
      answers.removeAll { $0 == element }
      
      for i in 0...2 {
        let randomElement = answers.randomElement()
        buttons[i].setTitle(processName(name: randomElement!), for: .normal)
        answers.removeAll {$0 == randomElement }
      }
    }
    
    if round == 19 {
      fillPictures()
      let alert = UIAlertController(title: "Your score:", message: "\(scoreLabel.text!) points!", preferredStyle: .alert)
      let action = UIAlertAction(title: "Done", style: .default, handler: {action in self.startGame()})
      alert.addAction(action)
      present(alert, animated: true)
      auidioPlayer.play()
      
      round = 0
      score = 0
    }
    answers = uniqueAnswers
  }
  
  private func getRandomIndex(array: [String]) -> Int {
    return Int(arc4random_uniform(UInt32(array.count)))
  }
  
  private func getRandomIndex(array: [UIButton]) -> Int {
    return Int(arc4random_uniform(UInt32(array.count)))
  }
  
  private func correctAnswer() {
    score += Game.plusScore
    scoreLabel.text = String.init(describing: score)
  }
  
}
