if (navigator.mediaDevices) {
    console.log('getUserMedia supported.');

    const constraints = {audio: false, video: true};
    const chunks = [];

    navigator.mediaDevices.getUserMedia(constraints)
        .then (stream) => { 
            const options = {
                audioBitsPerSecond: 128000,
                videoBitsPerSecond: 2500000,
                 
            // this would create .mp4 video ;;- 'video/webm'
                mimeType: "video/mp4",
                codecs= "avc1.424028,mp4a.40.2"
            }
            const mediaRecorder = new MediaRecorder(stream, options);
            m = mediaRecorder;

            m.mimeType;
        };
            .catch ((error) => {
                console.error(error.message);
            });
        }