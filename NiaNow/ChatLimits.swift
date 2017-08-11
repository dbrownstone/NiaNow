//
//  ChatLimits.swift
//  NiaNow
//
//  Created by David Brownstone on 11/08/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit

class ChatLimits: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var modeClass = true
    var returnToSettings = "returnToSettings"
    let classChoices = ["One Day", "Seven Days", "30 Days", "6 Months", "1 Year", "Never"]
    let classChoicesDictionary = ["One Day": 1, "Seven Days": 7, "30 Days": 30, "6 Months": 183, "1 Year": 366, "Never" : -1]
    let individualChoices = ["One Day", "Seven Days", "30 Days"]
    let individualChoicesDictionary = ["One Day": 1, "Seven Days": 7, "30 Days": 30]
    
    var selectedEntry:String?
    @IBOutlet weak var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        picker.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setAction(_ sender: Any) {
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToSettings", sender: self)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if modeClass {
            return self.classChoices.count
        }
        return self.individualChoices.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if modeClass {
            return self.classChoices[row]
        }
        return self.individualChoices[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if modeClass {
            selectedEntry = self.classChoices[row]
        } else {
            selectedEntry = self.individualChoices[row]
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
