# SwiftAudioRecording
a simple audio recording example using Swift, AVFoundation

## Notice
This source code is design for recording using Soundflower, but it doesn't limit you. You can use any input device or the default device.  
Please pay attention to this code, change whatever device you want
```swift
let captureDevice = getDevices(name: "Soundflower (2ch)")
```

## Integrate Soundflower

### Build Soundfower

```bash
git clone https://github.com/luanvuhlu/Soundflower
cd Soundflower
./build_kext.rb dep
./installer.rb
```

Install the sound driver at **Soundfower/Build/Soundflower-{version}.dmg**
Change the output device to **Soundflower (2ch)**


### Build Audio Record app

```bash
git clone https://github.com/luanvuhlu/SwiftAudioRecording
cd SwiftAudioRecording
./build.rb dep
```

### Test
Run the audio recorder application at **SwiftAudioRecording/build/Release/AudioRecord.app**  
Play any sound on the device  
Click **Record** button on the application. Click **Record** button again to stop recording
