//
//  Question.swift
//  Mroute
//
//  Created by Zhongheng Hu on 24/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//  The question class that store the value into object.

import Foundation

class Question: NSObject {
    
    let number: Int
    let question: String
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctAnswer: Int
    let questiondescription: String
    
    init(questionText: String, choiceA: String, choiceB: String, choiceC: String, choiceD: String, answer: Int, qNumber: Int, qDescription: String) {
        question = questionText
        optionA = choiceA
        optionB = choiceB
        optionC = choiceC
        optionD = choiceD
        correctAnswer = answer
        number = qNumber
        questiondescription = qDescription
    }
}
