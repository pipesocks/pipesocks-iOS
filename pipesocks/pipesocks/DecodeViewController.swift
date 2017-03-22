/*
 This file is part of pipesocks-iOS. Pipesocks-iOS is a pipesocks tap running on iOS. Pipesocks is a pipe-like SOCKS5 tunnel system.
 Copyright (C) 2017  yvbbrjdr
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit
import AVFoundation

class DecodeViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var scanPlaceHolder: UIImageView!
    var captureSession:AVCaptureSession?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        do {
            let captureDevice=AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            let captureInput=try AVCaptureDeviceInput.init(device: captureDevice)
            captureSession=AVCaptureSession.init()
            captureSession?.addInput(captureInput)
            let captureMetadataOutput=AVCaptureMetadataOutput.init()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes=[AVMetadataObjectTypeQRCode]
            let videoPreviewLayer=AVCaptureVideoPreviewLayer.init(session: captureSession)
            videoPreviewLayer!.videoGravity=AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.frame=scanPlaceHolder.bounds
            scanPlaceHolder.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
        } catch {
            let notValid=UIAlertController.init(title: "Error", message: "Camera access denied!", preferredStyle: .alert)
            let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            notValid.addAction(OKButton)
            self.present(notValid, animated: true, completion: nil)
            return
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects==nil||metadataObjects.count==0 {
            return
        }
        for metadataObject in metadataObjects {
            if (metadataObject as AnyObject).type==AVMetadataObjectTypeQRCode {
                SettingsViewController.url=(metadataObject as! AVMetadataMachineReadableCodeObject).stringValue
                captureSession?.stopRunning()
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
    }

    @IBAction func enterLinkClicked() {
        let getURL=UIAlertController.init(title: "Enter URL", message: "Please enter the URL below", preferredStyle: UIAlertControllerStyle.alert)
        let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
            SettingsViewController.url=getURL.textFields?.first?.text
            self.navigationController?.popViewController(animated: true)
        }
        let CancelButton=UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        getURL.addTextField { (textField) in
            textField.keyboardType=UIKeyboardType.URL
            textField.text=UIPasteboard.general.string ?? ""
        }
        getURL.addAction(CancelButton)
        getURL.addAction(OKButton)
        present(getURL, animated: true, completion: nil)
    }

    @IBAction func loadClicked() {
        let picker=UIImagePickerController.init()
        picker.sourceType = .photoLibrary
        picker.allowsEditing=false
        picker.delegate=self
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var ok:Bool=false
        let chosenImage=info[UIImagePickerControllerOriginalImage] as! UIImage
        let detector=CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        let features=detector?.features(in: CIImage.init(image: chosenImage)!)
        if features!.count>0 {
            for feature in features! {
                if feature.type==CIFeatureTypeQRCode {
                    SettingsViewController.url=(feature as! CIQRCodeFeature).messageString
                    ok=true
                    break
                }
            }
        }
        dismiss(animated: true) {
            if ok {
                self.navigationController?.popViewController(animated: true)
            } else {
                let qrFailed=UIAlertController.init(title: "Error", message: "No QR Code is detected!", preferredStyle: UIAlertControllerStyle.alert)
                let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                qrFailed.addAction(OKButton)
                self.present(qrFailed, animated: true, completion: nil)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
