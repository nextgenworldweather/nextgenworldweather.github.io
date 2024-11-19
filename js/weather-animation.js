// Weather map animation script
// Author: Peter Nunekpeku | pnunekpeku5@gmail.com
// Modified to work with weather-map.html

window.addEventListener('load', function() {
    // Initialize controls
    const playbackControls = document.querySelector('.playback-controls');
    if (playbackControls) {
        playbackControls.style.display = 'flex';
    }

    // Setup legend interactions
    const legendScale = document.querySelector('.legend-scale');
    const legendLabels = document.querySelectorAll('.legend-label');
    const legendColors = document.querySelectorAll('.legend-color');

    if (legendScale) {
        legendScale.addEventListener('mouseover', () => {
            legendLabels.forEach(label => label.style.visibility = 'visible');
            legendColors.forEach(color => color.style.visibility = 'visible');
        });

        legendScale.addEventListener('mouseout', () => {
            legendLabels.forEach(label => label.style.visibility = 'hidden');
            legendColors.forEach(color => color.style.visibility = 'hidden');
        });

        legendScale.addEventListener('dblclick', () => {
            legendLabels.forEach(label => label.style.display = 'block');
            legendColors.forEach(color => color.style.display = 'block');
            legendScale.style.display = 'block';
        });
    }

    // Store forecast images
    let forecasts = [];
    let forecastIndex = 0;
    let animationInterval = null;

    // Function to initialize forecasts
    function initForecasts() {
        const images = document.querySelectorAll("#map img.leaflet-image-layer.leaflet-zoom-animated");
        forecasts = Array.from(images);
        
        if (forecasts.length === 0) {
            console.warn('No forecast images found');
            return false;
        }

        // Remove all images except the first one
        forecasts.forEach((img, index) => {
            if (index > 0) {
                img.remove();
            }
        });

        return true;
    }

    // Initialize forecasts
    if (!initForecasts()) {
        return; // Exit if no forecasts found
    }

    const totalForecasts = forecasts.length;

    // Animation control functions
    function nextForecast() {
        goToForecast((forecastIndex + 1) % totalForecasts);
    }

    function previousForecast() {
        goToForecastReverse((forecastIndex - 1 + totalForecasts) % totalForecasts);
    }

    function goToForecast(n) {
        const overlayPane = document.querySelector("#map .leaflet-pane.leaflet-overlay-pane");
        if (!overlayPane || !forecasts[n]) return;

        forecastIndex = n;
        const currentImages = overlayPane.querySelectorAll('img');
        
        // Remove current images
        currentImages.forEach(img => img.remove());

        // Clone and add new image
        const newImage = forecasts[n].cloneNode(true);
        overlayPane.appendChild(newImage);

        // Update forecast info
        updateForecastInfo(newImage.src);
    }

    function goToForecastReverse(n) {
        goToForecast(n);
    }

    function updateForecastInfo(imageSrc) {
        try {
            const splitTitle = imageSrc.split("_");
            const splitTime = splitTitle[3].split(".");
            const date = splitTitle[2];
            const time = splitTime[0].replace(/-/g, ":");

            const forecastInfo = document.querySelector('.forecast-info');
            if (forecastInfo) {
                forecastInfo.innerHTML = `
                    <div class="forecast-date">${date}</div>
                    <div class="forecast-time">${time}</div>
                `;
            }
        } catch (error) {
            console.warn('Error updating forecast info:', error);
        }
    }

    // Setup animation controls
    let playing = true;
    animationInterval = setInterval(nextForecast, 750);

    // Play/Pause button
    const pauseButton = playbackControls.children[1];
    function pauseForecast() {
        pauseButton.textContent = '▶'; // play character
        playing = false;
        clearInterval(animationInterval);
    }

    function playForecast() {
        pauseButton.textContent = '❚❚'; // pause character
        playing = true;
        animationInterval = setInterval(nextForecast, 750);
    }

    pauseButton.onclick = () => {
        if (playing) {
            pauseForecast();
        } else {
            playForecast();
        }
    };

    // Previous/Next buttons
    const previousButton = playbackControls.children[0];
    const nextButton = playbackControls.children[2];

    previousButton.onclick = () => {
        pauseForecast();
        previousForecast();
    };

    nextButton.onclick = () => {
        pauseForecast();
        nextForecast();
    };
});
