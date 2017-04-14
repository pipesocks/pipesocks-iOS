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

class EncodeViewController: UIViewController {

    @IBOutlet weak var QRCode: UIImageView!
    static var url:String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if EncodeViewController.url != nil {
            let filter=CIFilter.init(name: "CIQRCodeGenerator", withInputParameters: [
                "inputMessage":NSData.init(data: EncodeViewController.url!.data(using: String.Encoding.ascii)!),
                "inputCorrectionLevel":"L"
                ])
            let image:CIImage=filter!.outputImage!
            let scale:CGFloat=min(QRCode.bounds.width, QRCode.bounds.height)/UIImage.init(ciImage: image).size.width
            scale=CGFloat.init(ceilf(Float.init(scale)))
            let transform:CGAffineTransform=CGAffineTransform.init(scaleX: scale, y: scale)
            QRCode.image=UIImage.init(ciImage: image.applying(transform))
        }
    }

    @IBAction func copyLinkClicked() {
        UIPasteboard.general.string=EncodeViewController.url
        let urlCopied=UIAlertController.init(title: "Success", message: "URL is copied!\n\(EncodeViewController.url!)", preferredStyle: UIAlertControllerStyle.alert)
        let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        urlCopied.addAction(OKButton)
        present(urlCopied, animated: true, completion: nil)
    }

    @IBAction func saveClicked() {
        let originalImage:UIImage=QRCode.image!
        UIGraphicsBeginImageContext(originalImage.size)
        originalImage.draw(in: CGRect.init(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
        let newImage:UIImage=UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(newImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let saveError=UIAlertController.init(title: "Error", message: "Unable to save the QR Code to your Photos!", preferredStyle: UIAlertControllerStyle.alert)
            let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            saveError.addAction(OKButton)
            present(saveError, animated: true, completion: nil)
        } else {
            let saveSucceed=UIAlertController.init(title: "Success", message: "The QR Code is saved to your Photos!", preferredStyle: UIAlertControllerStyle.alert)
            let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            saveSucceed.addAction(OKButton)
            present(saveSucceed, animated: true, completion: nil)
        }
    }
}
