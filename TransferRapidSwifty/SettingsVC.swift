//
//  SettingsVC.swift
//  TransferRapidSwifty
//
//  Created by Andrei Giuglea on 29/11/2019.
//  Copyright © 2019 Andrei Giuglea. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class SettingsVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
   
    var moneySelected : Int = 0
    var moneyTypes = ["€","$","RON"]
    var moneyValue = [1, 1.1, 4.78]
    
    @IBOutlet weak var moneyValueLabel: UILabel!
    
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserLabel.text! = (Auth.auth().currentUser?.email)!
        logOutButton.layer.cornerRadius = 25
        moneyValueLabel.text! = "\(moneyValue[moneySelected])\(moneyTypes[moneySelected])"
        
        
        getLatest { [weak self] (result) in
            
            DispatchQueue.main.async {
                switch result {
                                    
                    case .success(let response):
                                    
                                    
                        let dollar = response.rates["USD"]!
                        let dollarRound = Double(round(1000*dollar)/1000)
                        self?.moneyValue[1] = dollarRound
                        let romanianLeu = response.rates["RON"]!
                        let ronRound = Double(round(1000*romanianLeu)/1000)
                        self?.moneyValue[2] = ronRound
                        print(romanianLeu)
        //
                    case .failure: print("error")
                    }
                }
            }
        
        
        
        
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
       
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return moneyTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return moneyTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        moneySelected = row
        moneyValueLabel.text! = "\(moneyValue[moneySelected])\(moneyTypes[moneySelected])"
    }
    
    
    @IBAction func goSite(_ sender: Any) {
        if let url = URL(string: "https://www.transferrapid.com/index.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
       
        do{
            
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "LoggedIn")
            let dataBase = DataBase(defaulty: 1)
            dataBase.dropTable(tableName: "Transfer")
                presentingViewController?.dismiss(animated: true, completion: nil)
              }catch{
                  print(error)
              }
        
        
    }
    
    
    
    
    
    
}


  func getLatest(completion: @escaping (Result) -> Void) {
       let urlString = "http://data.fixer.io/api/latest?access_key=78393061a42b3ac215ec6f2cada75d3a"
    guard let url = URL(string: urlString) else { completion(.failure); return  }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
         
         guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else { completion(.failure); return }
         
         do {
             
             let exchangeRates = try JSONDecoder().decode(rates.self, from: data)
             completion(.success(exchangeRates))
         }
         catch { completion(.failure) }
         
         }.resume()
}
