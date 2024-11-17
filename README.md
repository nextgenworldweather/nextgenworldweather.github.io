# Eastwind Consult Weather Forecasting Platform 🌦️  

[![GPL-3.0 License](https://img.shields.io/badge/license-GPL--3.0-blue)](./LICENSE.md)  
[![GitHub Pages](https://img.shields.io/badge/deployment-GitHub%20Pages-blue)](https://nextgenworldweather.github.io)  
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen)](https://github.com/nextgenworldweather/nextgenworldweather.github.io/issues)  

Eastwind Consult harnesses the power of the Weather Research and Forecasting (WRF) model initialized with Global Forecast System (GFS) data to deliver precise and reliable weather predictions. Our platform provides dynamic visualizations using Leaflet maps with KML overlays, focusing on the regions of Australia, China, India, and West Africa.

Key Features:
High-Frequency Updates:

Weather forecasts are updated every 15 minutes, ensuring the most current and accurate data.

Detailed Forecasts:

Rainfall predictions are enhanced with overlays showing wind direction, wind speed, atmospheric pressure, and pressure centers (High and Low).

Interactive Visualizations:

Utilizes Leaflet maps with KML overlays to provide an interactive user experience.

Regional Focus:

Tailored forecasting for Australia, China, India, and West Africa, allowing for region-specific weather insights. 

---

## 📱 Using the Platform

1. Visit [EastwindConsult Weather](https://nextgenworldweather.github.io)
2. Select your region of interest
3. Choose from available regions and weather parameters:
   - Reflectivity
   - Outgoing Long-wave Radiation
   - Rainfall
   - Temperature
4. View the WRF-generated forecast

---

## 🌟 Features  

- Numerical weather predictions using the WRF model  
- Leaflet integration for interactive map-based forecast displays  
- Rainfall overlay with wind direction, speed, and pressure data, including High (H) and Low (L) pressure centers  
- Initialization of WRF forecasts using GFS data
- Responsive, user-friendly design tailored to different devices  

---

## 🔮 Weather Research and Forecasting (WRF) Model  

The platform utilizes the WRF model, a next-generation mesoscale numerical weather prediction system designed for both atmospheric research and operational forecasting needs.  

**Key Features:**  
- Advanced physics parameterizations  
- High-resolution terrain and land-use data  
- Initialization with Global Forecast System (GFS) data for accurate predictions  

---

## 🌍 Regional Coverage  

- Australia  
- China  
- India  
- West Africa  

---

## 🎯 Forecast Parameters  

### Weather Parameters  
- **Reflectivity**
- **Outgoing Long-wave Radiation (OLR)**
- **Rainfall**: Precipitation forecasts, overlaid with wind direction, speed, and pressure data  
- **Temperature**

### Interactive Map Layers (via Leaflet.js):  
- KML-based weather forecasts (reflectivity, OLR, rainfall, temperature)  
- Dynamic overlays for:  
  - Rainfall with wind barbs (direction and speed)  
  - Pressure and pressure centers (H/L)  

---

## 🗺️ Visualization Using Leaflet  

**Leaflet.js Integration:**  
- Displays KML weather forecasts over interactive maps.
- Zoom in/out
- Pan across regions  

**Rainfall with Overlays:**  
- **Wind Overlay**: barbs represent wind direction and speed.  
- **Pressure Overlay**: High (H) and Low (L) pressure centers.  

---

## 🚀 Roadmap  

### Phase 1: Core Functionality (Completed ✅)  
- Launch weather forecasting for four regions.  
- Display KML forecasts on interactive Leaflet maps.  
- Overlay rainfall with wind direction, speed, and pressure data.  

### Phase 2: Enhancements (In Progress 🛠️)  
- Add more regions (e.g., Europe, North America, East Africa, South Africa).  
- Include additional parameters like humidity and cloud cover.  

### Phase 3: Community Tools (Planned 🔜)  
- Enable user feedback submissions for local weather anomalies.  
- Introduce multilingual support for global users.  
- Develop a mobile app version for Android and iOS.  

---

## 🔧 Technical Implementation  

### Technologies Used  
- HTML5 and CSS3 for design and layout  
- Leaflet.js for map visualization and KML overlays  
- WRF Model for forecast generation  
- GFS data initialization for WRF forecasts 

### Browser Support  
- Chrome, Firefox, Safari, Edge, Opera (latest versions)  

---

## 🚀 Getting Started  

### Clone the Repository  
```bash
git clone https://github.com/nextgenworldweather/nextgenworldweather.github.io.git
