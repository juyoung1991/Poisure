//
//  SecondViewController.swift
//  measure_object
//
//  Created by Ju Young Kim on 2016. 12. 26..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit

class UserInputViewController: UIViewController {

    
    @IBOutlet weak var camera_height: UITextField!
    
    @IBOutlet weak var meter_btn: UIButton!
    @IBOutlet weak var ft_btn: UIButton!
    @IBOutlet weak var start_btn: UIButton!
    var usingMeter:Bool = true
    /**
     Move to second tab bar to start measuring item
     **/
    @IBAction func use_meter(_ sender: Any) {
        usingMeter = true
        meter_btn.layer.backgroundColor = UIColor.init(red: 204/255, green: 229/255, blue: 1, alpha: 1).cgColor
        ft_btn.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    @IBAction func use_ft(_ sender: Any) {
        usingMeter = false
        ft_btn.layer.backgroundColor = UIColor.init(red: 204/255, green: 229/255, blue: 1, alpha: 1).cgColor
        meter_btn.layer.backgroundColor = UIColor.clear.cgColor
    }
    

    @IBAction func start_measure(_ sender: Any) {
        if(self.camera_height.text == "" || Double(camera_height.text!) == nil){
            let alert = UIAlertController(title: "Oops!", message: "Please enter a valid camera height!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.performSegue(withIdentifier: "start", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "start"){
            var measure_vc = segue.destination as! MeasureViewController
            if(camera_height.text! == "" || Double(camera_height.text!) == nil){
                print("hello")
                return
            }else{
                print("in here?")
                measure_vc.camera_height = Double(camera_height.text!)!
                measure_vc.usingMeter = self.usingMeter
            }
        }
    }
    /**
     Dismiss keyboard when return is pressed
     **/
    @IBAction func textFieldReturn(sender: UITextField){
        sender.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        start_btn.layer.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 1).cgColor
        start_btn.layer.cornerRadius = 4
        camera_height.text = nil
        usingMeter = true
        meter_btn.layer.borderColor = UIColor.gray.cgColor
        meter_btn.layer.borderWidth = 0.6
        meter_btn.layer.backgroundColor = UIColor.init(red: 204/255, green: 229/255, blue: 1, alpha: 1).cgColor
        ft_btn.layer.borderColor = UIColor.gray.cgColor
        ft_btn.layer.borderWidth = 0.6
        ft_btn.layer.backgroundColor = UIColor.clear.cgColor
    }
    /**
     Dismiss keyboard when tabbed outside the keyboard
     **/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

