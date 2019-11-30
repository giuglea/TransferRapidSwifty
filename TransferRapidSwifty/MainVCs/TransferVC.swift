//
//  ViewController.swift
//  TransferRapidSwifty
//
//  Created by Andrei Giuglea on 27/11/2019.
//  Copyright © 2019 Andrei Giuglea. All rights reserved.
//

import UIKit
import AudioToolbox

class TransferVC: UIViewController {
 ///TODO: 1001 sum?
//
//    - între 1-100 Euro: comision 2%
//    - între 101-500 Euro: comision 3%
//    - între 501-1000 Euro: comision 4%
    
    var sum : Int = 0
    var commission : Int = 2
    var accountName = "Me"
    
    let urlString = "http://data.fixer.io/api/latest?access_key=78393061a42b3ac215ec6f2cada75d3a"
    
    var moneySelected : Int = 0
    var moneyTypes = ["€","$","RON"]
    var moneyValue = [1, 1.1, 4.78]
    
    let phoneInfoArray = ["Phone Number in Romania", "Phone Numbers in United Kingdom, France", "Phone Numbers in Spain, Italy, Germany", "Phone Number for Other Countries"]
    let phoneNumberArray = ["0800.800.609","+800.8000.5050","+800.8000.5050","+4021.320.9020"]
    
    
    var counter = 0
    
    
    @IBOutlet weak var sumSlider: UISlider!
    @IBOutlet weak var sumText: UITextField!
    @IBOutlet weak var feeValue: UILabel!
    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var feePercent: UILabel!
    
    
    
    @IBOutlet weak var firstLabelSlider: UILabel!
    @IBOutlet weak var secondLabelSlider: UILabel!
    @IBOutlet weak var thirdLabelSlider: UILabel!
    
    
    
    @IBOutlet weak var destination: UITextField!
    
    @IBOutlet weak var phoneInfo: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
   
    
    
    @IBOutlet weak var firstInterval: UIButton!
    @IBOutlet weak var secondInterval: UIButton!
    @IBOutlet weak var thirdInterval: UIButton!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sumSlider.minimumValue = 1
        sumSlider.maximumValue = 100

        transferButton.layer.cornerRadius = 25
        transferButton.isHidden = true
        
        firstInterval.isEnabled = false
        
        var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)
        timer.fire()
        
        feeValue.text = "0"
        
        getLatest { [weak self] (result) in
        
        DispatchQueue.main.async {
            switch result {
                            
                    case .success(let response):
                            
                            
                        let dollar = response.rates["USD"]!
                        self?.moneyValue[1] = dollar
                        let romanianLeu = response.rates["RON"]!
                        self?.moneyValue[2] = romanianLeu
                        print(romanianLeu)
//
                    case .failure: print("error")
                    }
            }
        }
  
        
    }


    
    @IBAction func changeSum(_ sender: Any) {
        
        sumSlider.value = round(sumSlider.value)
        calculateFee()
        feePercent.text = "\(commission)%"
        if( round(sumSlider.value) != 0 ){
            transferButton.isHidden = false
        }else{
            transferButton.isHidden = true
        }
        
        switch moneySelected {
        case 0:
            sumText.text! = "\(Int(sumSlider.value))€"
            feeValue.text = "\(Int(commission*Int(sumSlider.value)/100))€"
            
            if(Int(commission*Int(sumSlider.value)/100)==0){
                feeValue.text  = "1€"
            }
//        case 1:
//            sumText.text! = "\(Int(sumSlider.value*1.1))$"
//            commisionValue.text = "\(Int(commission*Int(sumSlider.value)*1.1/100))$"
//        case 2:
//            sumText.text! = "\(Int(sumSlider.value*4.78))RON"
//            commisionValue.text = "\(Int(commission*Int(sumSlider.value)*1.1/100))RON"
        default:
            sumText.text! = "\(Int(sumSlider.value))€"
            feeValue.text = "\(Int(commission*Int(sumSlider.value))/100)€"
        }
        
    
        
    }
    
    
    @objc func calculateFee(){
        
        switch (round(sumSlider.value)) {
            
        case (1...100):
            commission = 2
            
        case (101...500):
            commission = 3
            
        case (501...1000):
            commission = 4
            
        default:
            commission = 2
        }
        feePercent.text = "\(commission)%"
        feeValue.text = "\(Int(commission*Int(sumSlider.value))/100)€"
        
    }
    func sumSliderModifier(withCase:Int){
        switch withCase {
        case 0:
            sumSlider.minimumValue = 1
            sumSlider.maximumValue = 100
            firstLabelSlider.text = "0€"
            secondLabelSlider.text = "50€"
            thirdLabelSlider.text = "100€"
            firstInterval.isEnabled = false
            secondInterval.isEnabled = true
            thirdInterval.isEnabled = true
            
        case 1:
            sumSlider.minimumValue = 100
            sumSlider.maximumValue = 500
            firstLabelSlider.text = "100€"
            secondLabelSlider.text = "300€"
            thirdLabelSlider.text = "500€"
            firstInterval.isEnabled = true
            secondInterval.isEnabled = false
            thirdInterval.isEnabled = true
            
            
        case 2:
            sumSlider.minimumValue = 500
            sumSlider.maximumValue = 1000
            firstLabelSlider.text = "500€"
            secondLabelSlider.text = "750€"
            thirdLabelSlider.text = "1000€"
            firstInterval.isEnabled = true
            secondInterval.isEnabled = true
            thirdInterval.isEnabled = false
            
        default:
            sumSlider.minimumValue = 1
            sumSlider.maximumValue = 100
            firstLabelSlider.text = "0€"
            secondLabelSlider.text = "50€"
            thirdLabelSlider.text = "100€"
            firstInterval.isEnabled = false
            secondInterval.isEnabled = true
            thirdInterval.isEnabled = true
        }
        transferButton.isHidden = false
    }
    
    @IBAction func changeMoneySelected(_ sender: Any) {
        sumSliderModifier(withCase: 0)
        sumSlider.updateConstraints()
    }
    
    @IBAction func changeMoneySelected500(_ sender: Any) {
        sumSliderModifier(withCase: 1)
        sumSlider.updateConstraints()
    }
    
    @IBAction func changeMoneySelected1000(_ sender: Any) {
        sumSliderModifier(withCase: 2)
        sumSlider.updateConstraints()
    }
    
    
    
    @IBAction func transfer(_ sender: Any) {
       
        if(destination.text! != "" ){
        
            var transferObject = TransferObject(sender: "\(accountName)", receiver: destination.text!, date: "", value: (Int(sumSlider.value)))
            var dataBase = checkCreateDatabase()
            dataBase.createTable(createTableString: "CREATE TABLE Transfer(Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Sender CHAR(255), Data CHAR(255), Value INT, Receiver  CHAR(255) );")
            
            let insertStatementString = "INSERT INTO Transfer (Id, Sender, Data, Value, Receiver) VALUES (?, ?, ?, ?, ?);"
            let isSuccesful = dataBase.insert(sender: transferObject.sender, receiver: transferObject.receiver, value: transferObject.value, insertStatementString: insertStatementString)
            
            
            if(isSuccesful){
                let intSum = Int(sumSlider.value)
                var commisionValue = commission*intSum/100
                if(commisionValue == 0) {commisionValue = 1}
                let alert = UIAlertController(title: "Succes!", message: "Ati trimis \(intSum - commisionValue)€ catre \(destination.text!)", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok😁", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Eroare", message: "Transferul sumei a esuat", preferredStyle: UIAlertController.Style.alert)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                alert.addAction(UIAlertAction(title: "Ok🥺", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Atentie!", message: "Nu ati introdus o destinatie", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

      
    }
    
    
    @objc func processTimer() {
        counter += 1
        if(counter%5==0){
            changePhoneLabel()
            print(counter)
        }
        if(counter==20){
            counter=0
        }
        
    }
    
    func  changePhoneLabel(){
        
        switch (counter) {
            
        case 0...5:
            phoneInfo.fadeTransition(0.4)
            phoneInfo.text = phoneInfoArray[0]
            phoneNumber.fadeTransition(0.4)
            phoneNumber.text = phoneNumberArray[0]//0
            
        case 6...10:
            phoneInfo.fadeTransition(0.4)
            phoneInfo.text = phoneInfoArray[1]
            phoneNumber.fadeTransition(0.4)
            phoneNumber.text = phoneNumberArray[1]
            
        case 11...15:
            phoneInfo.fadeTransition(0.4)
            phoneInfo.text = phoneInfoArray[2]
            phoneNumber.fadeTransition(0.4)
            phoneNumber.text = phoneNumberArray[2]
            
        case 16...20:
            phoneInfo.fadeTransition(0.4)
            phoneInfo.text = phoneInfoArray[3]
            phoneNumber.fadeTransition(0.4)
            phoneNumber.text = phoneNumberArray[3]
            
        default:
            phoneInfo.fadeTransition(0.4)
            phoneInfo.text = phoneInfoArray[0]
            phoneNumber.fadeTransition(0.4)
            phoneNumber.text = phoneNumberArray[0]
        }
    }
    
    
    @IBAction func callCenter(_ sender: Any) {
        
        guard let numberString = phoneNumber?.text,let url = URL(string: "telprompt://\(numberString)")else{return}
        UIApplication.shared.openURL(url)
        print("ok")
        
    }
    
    @IBAction func editingBegun(_ sender: Any) {
        
        sumText.text! = "\(Int(sumSlider.value))"
    }
    
    
    @IBAction func editingEnded(_ sender: Any) {
        
        
        
        let sumInt: Int = Int(sumText.text!) ?? 0
        switch (sumInt) {
        case 0:
            transferButton.isHidden = true
        case 1...100:
            sumSliderModifier(withCase: 0)
        case 101...500:
            sumSliderModifier(withCase: 1)
        case 501...1000:
            sumSliderModifier(withCase: 2)
        case _ where sumInt>1000:
            print("WTF")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            sumSliderModifier(withCase: 2)
            sumText.text! = "1000"
            ///TODO: bAlerta
            let alert = UIAlertController(title: "Atentie!", message: "Ati introdus o suma prea mare \n Limita este de 1000€", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        default:
            sumSliderModifier(withCase: 0)
        }
        sumSlider.value =  Float(sumText.text!) as! Float  ?? 1.0
        sumText.text! = "\(sumText.text!)\(moneyTypes[moneySelected])"
        calculateFee()
        
    }
    
   
    
//    @IBAction func showHistory(_ sender: Any) {
//        let intSum = Int(sumSlider.value)
//        if(intSum != 0){
//            performSegue(withIdentifier: "showHistory", sender: self)
//        }else{
//            return
//        }
//
//    }
    
    
    
}




struct rates: Decodable {
    
    var date: String
    var base: String
    var rates: [String: Double]
}

enum Result {
    
    case failure
    case success(rates)
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
