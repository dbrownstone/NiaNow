//
//  ChatLimits.swift
//  NiaNow
//
//  Created by David Brownstone on 11/08/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit

/**
 Set the amount of time that a chat message is kept in the database and displayed in the chat (Class or individual - one-on-one) screen
 */
class ChatLimits: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    /// true for Class Chat messages; false for one on one messages
    var modeClass = true
    var returnToSettingsSegue = "returnToSettings"
    
    let classChoices = ["One Day", "Seven Days", "14 Days", "21 Days", "30 Days", "6 Months", "1 Year", "Never"]
    let individualChoices = ["One Day", "Seven Days", "14 Days", "21 Days", "30 Days"]
    
    let classChoicesDictionary = ["One Day": 1, "Seven Days": 7, "14 Days": 14, "21 Days": 21, "30 Days": 30, "6 Months": 180, "1 Year": 366, "Never" : -1]
    let individualChoicesDictionary = ["One Day": 1, "Seven Days": 7, "14 Days": 14, "21 Days": 21, "30 Days": 30]
    
    var selectedKey:String?
    var selectedResult:Int?
    var selectedDict:[String: Int] = [:]
    
    @IBOutlet weak var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        picker.dataSource = self
        
        var chatMode = "One-on-one"
        if modeClass {
            chatMode = "Class"
        }
        self.title = "Set the Amount of Time to Retain and Display Messages\nfor \(chatMode) Chat"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setAction(_ sender: Any) {
        selectedResult = modeClass ? classChoicesDictionary[selectedKey!] : individualChoicesDictionary[selectedKey!]
        selectedDict = [selectedKey! : selectedResult!]
        cancelAction(self)
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.performSegue(withIdentifier: returnToSettingsSegue, sender: self)
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
            selectedKey = self.classChoices[row]
        } else {
            selectedKey = self.individualChoices[row]
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
