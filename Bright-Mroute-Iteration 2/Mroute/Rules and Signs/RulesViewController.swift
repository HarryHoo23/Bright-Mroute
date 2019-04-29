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
    
    @IBAction func quitButton(_ sender: Any) {
        //the next button that shows the next question when click.
        questionNumber += 1
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
    var buttonsArray = [UIButton]()
    
    override func viewDidLoad() {
        randomQuestions()
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!) // the background image of this view Controller
        self.view.contentMode = UIView.ContentMode.scaleAspectFill

        buttonsArray = [optionA, optionB, optionC, optionD] // set the button into an array.
        
        if resultArray.count != 0 {
            updateQuestion()
            updateProgress()
        }
    }

    
    @IBAction func answerPress(_ sender: UIButton) {
        //when the button of choice is clicked.
        let popVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popView") as! PopUpViewController
        self.addChild(popVc)
        popVc.view.frame = self.view.frame
        self.view.addSubview(popVc.view) // add the view to the view controller to show.
        popVc.didMove(toParent: self)
        //show the popUp window to show the answer. Automatically.
        
        popVc.descriptionLabel.text = ruleDescription
        
        if sender.tag == selectedAnswer { // if it is equal, the answer is correct, else it's wrong.
            popVc.answerLabel.text = "You are Correct!!"
            popVc.answerLabel.textColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
            popVc.descriptionImage.loadGif(name: "\(resultArray[questionNumber].number)dong")
        } else {
            popVc.answerLabel.text = "You are Wrong! The Answer is:  \(buttonsArray[selectedAnswer].currentTitle!)"
            popVc.answerLabel.textColor = UIColor.red
            popVc.descriptionImage.loadGif(name: "\(resultArray[questionNumber].number)dong")
        }
    }
    
    func updateQuestion(){ // This function is updating question when use hit next button, go to the next question.
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
            alert() // show alert.
        }
        updateProgress()
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
    }
    
}


extension RulesViewController{
    
    func randomQuestions(){ // this function shows the questions randomly.
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
    
    func alert(){ // This function shows the alert when the quiz is finished.
        // when finished show alert.
        let alert = UIAlertController(title: "End of Quiz", message: "Do you want to restart?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction) -> Void in self.restartQuiz()})
        let endAction = UIAlertAction(title: "No", style: .default, handler: {action in self.dismiss(animated: false, completion: nil)})
        alert.addAction(yesAction)
        alert.addAction(endAction)
        present(alert, animated: true, completion: nil)
    }
    
    func restartQuiz(){ // This function is called when the user hit the yes button to restart the quiz.
        // restart the quiz function.
        questionNumber = 0 // set the questionNumber back to 0.
        randomQuestions()
        updateQuestion()
    }
}
