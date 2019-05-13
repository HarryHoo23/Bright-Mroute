//
//  RulesViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 31/3/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//
//  This viewController will be responsible for the Quiz page. Let user to do the quiz. 

import UIKit

class RulesViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func quitButton(_ sender: Any) {
        //the next button that shows the next question when click.
        questionNumber += 1
        optionA.isEnabled = true
        optionB.isEnabled = true
        optionC.isEnabled = true
        optionD.isEnabled = true
        optionA.backgroundColor = UIColor(red: 252/255, green: 255/255, blue: 72/255, alpha: 0.75)
        optionB.backgroundColor = UIColor(red: 252/255, green: 255/255, blue: 72/255, alpha: 0.75)
        optionC.backgroundColor = UIColor(red: 252/255, green: 255/255, blue: 72/255, alpha: 0.75)
        optionD.backgroundColor = UIColor(red: 252/255, green: 255/255, blue: 72/255, alpha: 0.75)
        updateQuestion()
    }
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var optionA: UIButton!
    @IBOutlet weak var optionB: UIButton!
    @IBOutlet weak var optionC: UIButton!
    @IBOutlet weak var optionD: UIButton!
    
    var questions = [Question]()
    var resultArray = [Question]()
    var ruleDescription: String?
    var questionNumber: Int = 0
    var selectedAnswer: Int = 0
    var score: Int = 0
    var buttonsArray = [UIButton]()
    var picture = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let blueColor = UIColor(red: 137/255, green: 196/255, blue: 244/255, alpha: 1)
        let grayColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
        view.setGradientBackgroundColor(colorOne: blueColor, colorTwo: grayColor)// the background image of this view Controller
        questionImage.layer.cornerRadius = 10
        optionA.applyButton()
        optionB.applyButton()
        optionC.applyButton()
        optionD.applyButton()
        
        buttonsArray = [optionA, optionB, optionC, optionD] // set the button into an array.
        if resultArray.count != 0 {
            restartQuiz()
            updateProgress()
        }
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for data in items {
            if data.hasSuffix("gif") {
                picture.append(data)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        randomQuestions()
        viewDidLoad()
    }
    
    @IBAction func answerPress(_ sender: UIButton) {
        //when the button of choice is clicked.
        let popVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popView") as! PopUpViewController
        self.addChild(popVc)
        popVc.view.frame = self.view.frame
        self.view.addSubview(popVc.view) // add the view to the view controller to show.
        popVc.didMove(toParent: self)
        //show the popUp window to show the answer.
        if picture.contains("\(resultArray[questionNumber].number)dong.gif") {
            print("Yes")
            popVc.descriptionLabel.text = ruleDescription
        } else {
            print("wrong")
            popVc.descriptionNewLabel.text = ruleDescription
        }
//        for name in picture {
//            if name.contains("\(resultArray[questionNumber].number)dong.gif")  {
//                popVc.descriptionLabel.text = ruleDescription
//                popVc.descriptionNewLabel.text = ""
//                print("\(resultArray[questionNumber].number)dong.gif")
//            } else {
//                print("Wrong")
//            }
//            if name != "\(resultArray[questionNumber].number)dong.gif" {
//                popVc.descriptionNewLabel.text = ruleDescription
//                popVc.descriptionLabel.text = ""
//                print("Wrong")
//            }
        //}
        if sender.tag == selectedAnswer { // if it is equal, the answer is correct, else it's wrong.
            score += 1
            popVc.answerLabel.text = "You are Correct!!"
            popVc.answerLabel.textColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
            popVc.descriptionImage.loadGif(name: "\(resultArray[questionNumber].number)dong")
            optionA.isEnabled = false
            optionB.isEnabled = false
            optionC.isEnabled = false
            optionD.isEnabled = false
        } else {
            popVc.answerLabel.text = "You are Wrong! The Answer is:  \(buttonsArray[selectedAnswer].currentTitle!)"
            popVc.answerLabel.textColor = UIColor.red
            popVc.descriptionImage.loadGif(name: "\(resultArray[questionNumber].number)dong")
            //buttonsArray[questions[questionNumber].correctAnswer].backgroundColor = UIColor(red: 17/255, green: 220/255, blue: 5/255, alpha: 0.2)
            buttonsArray[sender.tag].backgroundColor = UIColor(red: 255/255, green: 32/255, blue: 25/255, alpha: 0.2)
            optionA.isEnabled = false
            optionB.isEnabled = false
            optionC.isEnabled = false
            optionD.isEnabled = false
        }
        
        buttonsArray[resultArray[questionNumber].correctAnswer].backgroundColor = UIColor(red: 17/255, green: 220/255, blue: 5/255, alpha: 0.2)

    }
    
    func updateQuestion(){
        if questionNumber <= resultArray.count - 1 {
            //questionNumber start at 0, if it is less than resultArray.count, then the question can start.
            questionLabel.text = resultArray[questionNumber].question
            optionA.setTitle(resultArray[questionNumber].optionA, for: UIControl.State.normal)
            optionB.setTitle(resultArray[questionNumber].optionB, for: UIControl.State.normal)
            optionC.setTitle(resultArray[questionNumber].optionC, for: UIControl.State.normal)
            optionD.setTitle(resultArray[questionNumber].optionD, for: UIControl.State.normal)
            selectedAnswer = resultArray[questionNumber].correctAnswer
            ruleDescription = resultArray[questionNumber].questiondescription
            questionImage.image = UIImage(named: "\(resultArray[questionNumber].number)") //show image based on question number
        } else {
            self.performSegue(withIdentifier: "showScore", sender: self)
            //self.performSegue(withIdentifier: "showScore", sender: self)
            //alert() // show alert.
        }
        updateProgress()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ScoreViewController{
            let sc = segue.destination as? ScoreViewController
            sc?.score = self.score
        }
    }
    
    func updateProgress(){
        
        //this method update the progress of the quiz when going
        if questionNumber + 1 >= resultArray.count {
            questionNumberLabel.text = "\(resultArray.count)/ \(resultArray.count)"
            progressView.frame.size.width = (view.frame.size.width / CGFloat(resultArray.count)) * CGFloat(resultArray.count)
        } else {

            questionNumberLabel.text = "\(questionNumber + 1)/ \(resultArray.count)"
            progressView.frame.size.width = (view.frame.size.width / CGFloat(resultArray.count)) * CGFloat(questionNumber + 1) // the pregress view size is changing based on the question goes.
        }
            scoreLabel.text = "Score: \(score)"
    }
    
}


extension RulesViewController{
    func randomQuestions(){
        //choose random question from the database.
        var quizArray = [Question]()
        while quizArray.count < 10 && questions.count != 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(questions.count))) //create a random number1.
            let randomIndex2 = Int(arc4random_uniform(UInt32(questions.count)))// create a random number2.
            if randomIndex > randomIndex2 {
               quizArray.insert(questions[randomIndex - randomIndex2], at: 0) // insert into the new array.
            }else if randomIndex == randomIndex2{
                quizArray.insert(questions[randomIndex], at: 0) // insert into the new array.
            }else{
                quizArray.insert(questions[randomIndex2 - randomIndex], at: 0) // insert into the new array.
            }
            //we are doing this with if statement try to keep no repeat questions appers.
        }
        resultArray = quizArray
    }
    
    func alert(){
        // when finished show alert.
        let alert = UIAlertController(title: "End of Quiz", message: "Do you want to restart?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction) -> Void in self.restartQuiz()})
        let endAction = UIAlertAction(title: "No", style: .default, handler: {(action: UIAlertAction) -> Void in self.goHomePage()})
        alert.addAction(yesAction)
        alert.addAction(endAction)
        present(alert, animated: true, completion: nil)
    }
    
    func restartQuiz(){
        // restart the quiz function.
        questionNumber = 0 // set the questionNumber back to 0.
        score = 0
        randomQuestions()
        updateQuestion()
    }
    
    func goHomePage(){
        self.navigationController?.popViewController(animated: false)
    }
    

}

extension UIButton {
    func applyButton(){
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backgroundColor = UIColor(red: 252/255, green: 255/255, blue: 72/255, alpha: 0.75)
    }
}
