//
//  ScoreViewController.swift
//  Mroute
//
//  Created by Zhongheng Hu on 30/4/19.
//  Copyright © 2019 Zhongheng Hu. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class ScoreViewController: UIViewController {

    var score: Int?
    var condition: String?
    @IBOutlet weak var scoreView: MBCircularProgressBarView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var creditImage: UIImageView!
    
    var imageNames = ["average1", "average2", "average3", "average4", "average5", "average6", "average7","average8","average9","average10","average11","average12","average13","average14","average15","average16","average17","average18","average19","average20","average21","average22","average23","average24"]
    var excellentNames = ["excellent1","excellent2","excellent3","excellent4","excellent5","excellent6","excellent7","excellent8","excellent9","excellent10","excellent11","excellent12","excellent13","excellent14","excellent15","excellent16","excellent17","excellent18","excellent19","excellent20","excellent21","excellent22"]
    var poorNames = ["poor1","poor2","poor13","poor4","poor5","poor6","poor7","poor8","poor9","poor10","poor11","poor12","poor13","poor14","poor15","poor16","poor17","poor18","poor19"]
    var goodNames = ["good1","good2","good3","good4","good5","good6","good7","good8","good9","good10","good11","good12","good13","good14","good15","good16","good17","good18","good19","good20","good21","good22","good23","good24"]
    var image = [UIImage]()
    
    @IBAction func restart(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwind(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cloud")!.image(alpha: 0.9)!)
        //self.scoreView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        if (score! >= 0 && score! <= 2){
            conditionLabel.text = "Poor, really?"
            for i in 0..<poorNames.count{
                image.append(UIImage(named: poorNames[i])!)
            }
        } else if(score! >= 3 && score! <= 5){
            conditionLabel.text = "Average, not bad!"
            for i in 0..<imageNames.count{
                image.append(UIImage(named: imageNames[i])!)
            }
        } else if(score! >= 6 && score! <= 8){
            conditionLabel.text = "Good, you pass!"
            for i in 0..<goodNames.count{
                image.append(UIImage(named: goodNames[i])!)
            }
        } else if(score! >= 9 && score! <= 10){
            conditionLabel.text = "Excellent, you are an Expert!"
            for i in 0..<excellentNames.count{
                image.append(UIImage(named: excellentNames[i])!)
            }
        }
        self.scoreView.value = 0
        creditImage.animationImages = image
        creditImage.animationDuration = 4.0
        creditImage.animationRepeatCount = 1
        creditImage.startAnimating()
        creditImage.image = creditImage.animationImages?.last
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // Hide the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 4.0) {
            self.scoreView.value = CGFloat(self.score!)
            //self.scoreView.value = 10
        }
    }
    
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
