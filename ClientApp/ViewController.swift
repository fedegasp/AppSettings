//
//  ViewController.swift
//  ClientApp
//
//  Created by Federico Gasperini on 08/03/2021.
//

import UIKit
import AppSettings

class ViewController: UIViewController {

    @IBAction func openSettings(_ sender: Any?) {
        AppSettingsViewController.open(on: self)
    }
}

