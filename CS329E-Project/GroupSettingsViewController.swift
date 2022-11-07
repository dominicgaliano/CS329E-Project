//
//  GroupSettingsViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

class GroupSettingsViewController: UIViewController {

    @IBOutlet weak var qrCode: UIImageView!
    var qrcodeImage:CIImage! = nil
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeQrCode(groupName: "ghdos")


    }
    
    func makeQrCode(groupName:String){
        qrcodeImage = nil
        if groupName.isEmpty {return}
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {return}
        guard let data = groupName.data(using: .isoLatin1, allowLossyConversion: false) else {return}
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        qrcodeImage = filter.outputImage
        if let qrcodeImage = qrcodeImage{
            qrCode.image = UIImage(ciImage: qrcodeImage)
        }
    }
}
