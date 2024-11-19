// Screen recording script with mobile support
let btn = document.querySelector("#capture");
let isRecording = false;

// Check device type and capabilities
const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
const supportsScreenCapture = 'mediaDevices' in navigator && 'getDisplayMedia' in navigator.mediaDevices;
const supportsMobileCapture = 'mediaDevices' in navigator && 'getUserMedia' in navigator.mediaDevices;

// Configure optimal recording settings based on device
function getRecordingOptions() {
  if (isMobile) {
    return {
      video: {
        frameRate: { ideal: 30, max: 60 },
        width: { ideal: window.screen.width },
        height: { ideal: window.screen.height },
        facingMode: 'environment',
        displaySurface: 'browser',
        cursor: 'never'
      },
      audio: false
    };
  } else {
    return {
      video: {
        displaySurface: "browser",
        cursor: "always",
        frameRate: { ideal: 30, max: 60 },
        width: { ideal: 1920, max: 3840 },
        height: { ideal: 1080, max: 2160 }
      },
      audio: false,
      surfaceSwitching: "include",
      selfBrowserSurface: "include",
      systemAudio: "exclude"
    };
  }
}

// Create recording UI elements
function createRecordingUI() {
  const ui = document.createElement('div');
  ui.id = 'recording-ui';
  ui.style.cssText = `
    position: fixed;
    ${isMobile ? 'bottom: 20px;' : 'top: 20px;'}
    right: 20px;
    z-index: 10000;
    display: flex;
    flex-direction: column;
    gap: 10px;
    align-items: flex-end;
  `;

  const indicator = document.createElement('div');
  indicator.id = 'recording-indicator';
  indicator.style.cssText = `
    background: red;
    color: white;
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  `;
  
  const dot = document.createElement('span');
  dot.style.cssText = `
    width: 8px;
    height: 8px;
    background: white;
    border-radius: 50%;
    animation: blink 1s infinite;
  `;
  
  const style = document.createElement('style');
  style.textContent = `
    @keyframes blink {
      0% { opacity: 1; }
      50% { opacity: 0; }
      100% { opacity: 1; }
    }
  `;
  document.head.appendChild(style);
  
  indicator.appendChild(dot);
  indicator.appendChild(document.createTextNode('Rec'));
  ui.appendChild(indicator);

  const stopBtn = document.createElement('button');
  stopBtn.id = 'stop-recording';
  stopBtn.textContent = 'Stop';
  stopBtn.style.cssText = `
    padding: 8px 16px;
    background: #333;
    color: white;
    border: none;
    border-radius: 20px;
    cursor: pointer;
    font-weight: bold;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    ${isMobile ? 'font-size: 16px; padding: 12px 24px;' : ''}
  `;
  ui.appendChild(stopBtn);

  return { ui, stopBtn };
}

// Handle recording process
async function startRecording() {
  try {
    if (isRecording) return;
    isRecording = true;

    let stream;
    if (isMobile && !supportsScreenCapture && supportsMobileCapture) {
      // Fallback to camera for devices that don't support screen capture
      stream = await navigator.mediaDevices.getUserMedia(getRecordingOptions());
    } else {
      stream = await navigator.mediaDevices.getDisplayMedia(getRecordingOptions());
    }

    // Detect supported MIME types
    const mimeTypes = [
      'video/webm;codecs=vp9,opus',
      'video/webm;codecs=vp8,opus',
      'video/webm',
      'video/mp4'
    ];
    
    const supportedType = mimeTypes.find(type => MediaRecorder.isTypeSupported(type));
    if (!supportedType) {
      throw new Error('No supported video MIME types found');
    }

    const mediaRecorder = new MediaRecorder(stream, {
      mimeType: supportedType,
      videoBitsPerSecond: isMobile ? 1500000 : 2500000 // Adjust bitrate for mobile
    });

    const chunks = [];
    const { ui, stopBtn } = createRecordingUI();
    document.body.appendChild(ui);

    mediaRecorder.addEventListener('dataavailable', (e) => {
      if (e.data.size > 0) chunks.push(e.data);
    });

    mediaRecorder.addEventListener('stop', () => {
      isRecording = false;
      stream.getTracks().forEach(track => track.stop());

      const blob = new Blob(chunks, { type: supportedType });
      const url = URL.createObjectURL(blob);
      
      // Handle download based on device
      if (isMobile) {
        // For mobile, show preview and download options
        const modal = document.createElement('div');
        modal.style.cssText = `
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0,0,0,0.8);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          z-index: 10001;
        `;

        const video = document.createElement('video');
        video.src = url;
        video.controls = true;
        video.style.cssText = `
          max-width: 90%;
          max-height: 60vh;
          margin-bottom: 20px;
        `;

        const downloadBtn = document.createElement('button');
        downloadBtn.textContent = 'Download Recording';
        downloadBtn.style.cssText = `
          padding: 12px 24px;
          background: #007bff;
          color: white;
          border: none;
          border-radius: 20px;
          font-size: 16px;
          margin: 10px;
        `;

        const closeBtn = document.createElement('button');
        closeBtn.textContent = 'Close';
        closeBtn.style.cssText = `
          padding: 12px 24px;
          background: #666;
          color: white;
          border: none;
          border-radius: 20px;
          font-size: 16px;
          margin: 10px;
        `;

        modal.appendChild(video);
        modal.appendChild(downloadBtn);
        modal.appendChild(closeBtn);
        document.body.appendChild(modal);

        downloadBtn.onclick = () => {
          const a = document.createElement('a');
          const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
          a.href = url;
          a.download = `forecast-${timestamp}.${supportedType.includes('mp4') ? 'mp4' : 'webm'}`;
          a.click();
        };

        closeBtn.onclick = () => {
          modal.remove();
          URL.revokeObjectURL(url);
        };
      } else {
        // Desktop download
        const a = document.createElement('a');
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        a.style.display = 'none';
        a.href = url;
        a.download = `forecast-${timestamp}.${supportedType.includes('mp4') ? 'mp4' : 'webm'}`;
        document.body.appendChild(a);
        a.click();
        setTimeout(() => {
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
        }, 100);
      }

      ui.remove();
    });

    stopBtn.onclick = () => mediaRecorder.stop();
    mediaRecorder.start();

  } catch (err) {
    isRecording = false;
    console.error("Error recording screen:", err);
    alert(isMobile ? 
      "Unable to record on this device. Please try using a different browser or device." : 
      "Failed to start recording: " + err.message
    );
  }
}

// Initialize recording button
btn.addEventListener("click", startRecording);

// Add mobile-friendly styles to the capture button
if (isMobile) {
  btn.style.cssText = `
    padding: 12px 24px;
    font-size: 16px;
    border-radius: 20px;
    background: #007bff;
    color: white;
    border: none;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    margin: 10px;
  `;
}
