import SwiftUI
import CoreImage.CIFilterBuiltins


struct QRCodeView: View {
    let groupId: String
    
    var body: some View {
        VStack {
            Image(uiImage: generateQRCode(from: groupId))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("Scan QR Code to Join the Group")
                .font(.headline)
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
