import SwiftUI

struct RecordingView: View {
    
    let session = AudioCapture()
    
    var body: some View {
        Button(action: {
            tapped()
        }) {
            Text("Record").frame(maxWidth: 100, maxHeight: 100)
            
        }
    }
    
    func tapped() {
        session.record()
        print("Tapped")
    }
}

struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView()
    }
}
