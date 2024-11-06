**Easy To Integrate Maps & Location APIs & SDKs For Android Applications**

Powered with India's most comprehensive and robust mapping functionalities.

1. You can get your api key to be used in this document here: [https://about.mappls.com/api/signup](https://about.mappls.com/api/signup)

2. The sample code is provided to help you understand the basic functionality of Mappls maps & REST APIs working on **Flutter** development platform.

4. Explore through [200+ countries & territories](https://github.com/mappls-api/mappls-rest-apis/blob/main/docs/countryISO.md) with **Global Search, Routing and Mapping APIs & SDKs** by Mappls.

## [Documentation History](#Documentation-History)

| Version | Supported SDK Version |  
| ---- | ---- |    
| [v1.0.0](docs/v1.0.0/README.md) | - Map SDK v1.0.0 <br/> - Place Search Widget v1.0.0 <br/> - GeoFence Widget v1.0.0 <br/> - Direction Widget v1.0.0 <br/> - Nearby UI Widget v1.0.0 <br/> - Mappls Polyline v1.0.0 |

## [Version History](#Version-History)
| Version | Last Updated | Author |  Release Note| 
| ---- | ---- | ---- | ---- |
| v1.0.0 | 06 March 2023 | Mappls API Team ([MA](https://github.com/mdakram)) ([ST](https://github.com/saksham66)) |   -Initial release  |

For more details of previous versions , [click here](docs/v1.0.0/Version-History.md).

## [Table Of Content](#Table-Of-Content)
- [Vector Flutter Map](docs/v1.0.0/Getting-Started.md)
  - [Getting Started](docs/v1.0.0/Getting-Started.md#getting-started)
  - [API Usage](docs/v1.0.0/Getting-Started.md#api-usage)
  - [Installation](docs/v1.0.0/Getting-Started.md#installation)
  - [Add Your API keys to the SDK](docs/v1.0.0/Getting-Started.md#add-your-api-keys-to-the-sdk)
  - [Add Mappls Map to your application](docs/v1.0.0/Getting-Started.md#add-mappls-map-to-your-application)
  - [Map Interactions](docs/v1.0.0/Getting-Started.md#map-interactions)
  - [Map Events](docs/v1.0.0/Getting-Started.md#map-events)
  - [Map Overlays](docs/v1.0.0/Getting-Started.md#map-overlays)
    - [Add a Marker](docs/v1.0.0/Getting-Started.md#add-a-marker)
    - [Remove a Marker](docs/v1.0.0/Getting-Started.md#remove-a-marker)
    - [Customize a marker](docs/v1.0.0/Getting-Started.md#customize-a-marker)
    - [Add a Polyline](docs/v1.0.0/Getting-Started.md#add-a-polyline)
    - [Remove a Polyline](docs/v1.0.0/Getting-Started.md#remove-a-polyline)
    - [Add a Polygon](docs/v1.0.0/Getting-Started.md#add-a-polygon)
    - [Remove a Polygon](docs/v1.0.0/Getting-Started.md#remove-a-polygon)
    - [Show User location](docs/v1.0.0/Getting-Started.md#show-user-location)
- [Map Ui Settings](docs/v1.0.0/Map-Ui-Settings.md)
  - [Compass Setting](docs/v1.0.0/Map-Ui-Settings.md#compass-settings)
  - [Logo Settings](docs/v1.0.0/Map-Ui-Settings.md#logo-settings)
  - [Enable/ Disable Map Rotation Gesture](docs/v1.0.0/Map-Ui-Settings.md#enable-disable-map-rotation-gesture)
  - [Enable/Disable Map Scrolling Gesture](docs/v1.0.0/Map-Ui-Settings.md#enabledisable-map-scrolling-gesture)
  - [Enable/ Disable Map Tilt Gesture](docs/v1.0.0/Map-Ui-Settings.md#enable-disable-map-tilt-gesture)
  - [Enable/Disable Zoom Gesture](docs/v1.0.0/Map-Ui-Settings.md#enabledisable-zoom-gesture)
- [Set Mappls Map style](docs/v1.0.0/Mappls-Map-Style.md)
  - [List of Available Styles](docs/v1.0.0/Mappls-Map-Style.md#list-of-available-styles)
  - [Set Mappls Style](docs/v1.0.0/Mappls-Map-Style.md#set-mappls-style)
  - [To enable/disable last selected style](docs/v1.0.0/Mappls-Map-Style.md#to-enabledisable-last-selected-style)
  - [Get Selected style](docs/v1.0.0/Mappls-Map-Style.md#get-selected-style)
- [Rest APIs]
  - [Search APIs](docs/v1.0.0/Search-Api.md)
    - [Autosuggest](docs/v1.0.0/Search-Api.md#auto-suggest)
    - [Geocoding](docs/v1.0.0/Search-Api.md#geocoding)
    - [Reverse Geocoding](docs/v1.0.0/Search-Api.md#reverse-geocoding)
    - [Nearby Places](docs/v1.0.0/Search-Api.md#nearby-places)
    - [Place Details](docs/v1.0.0/Search-Api.md#place-details)
    - [POI Along the Route](docs/v1.0.0/Search-Api.md#poi-along-the-route)
  - [Routes & Navigation API](docs/v1.0.0/Routing-Api.md)
    - [Routing API](docs/v1.0.0/Routing-Api.md#routing-api)
    - [Driving Distance Matrix API](docs/v1.0.0/Routing-Api.md#driving-distance-matrix-api)
- [Mappls Pin Strategy](docs/v1.0.0/Mappls-Pin-Strategy.md)
- [Mappls Search Widget](docs/v1.0.0/Place-Autocomplete-Widget.md)
  - [Getting Started](docs/v1.0.0/Place-Autocomplete-Widget.md#getting-started)
  - [Adding Mappls Keys](docs/v1.0.0/Place-Autocomplete-Widget.md#adding-mappls-keys)
  - [Place Autocomplete](docs/v1.0.0/Place-Autocomplete-Widget.md#place-autocomplete)
  - [Place Picker](docs/v1.0.0/Place-Autocomplete-Widget.md#place-picker)
- [Mappls Direction Widget](docs/v1.0.0/Direction-Ui.md)
  - [Getting Started](docs/v1.0.0/Direction-Ui.md#getting-started)
  - [Adding Mappls Keys](docs/v1.0.0/Direction-Ui.md#adding-mappls-keys)
  - [Add Direction Widget](docs/v1.0.0/Direction-Ui.md#add-direction-widget)
- [Mappls Nearby Widget](docs/v1.0.0/Nearby-Widget.md)
  - [Getting Started](docs/v1.0.0/Nearby-Widget.md#getting-started)
  - [Adding Mappls Keys](docs/v1.0.0/Nearby-Widget.md#adding-mappls-keys)
  - [Add Nearby Widget](docs/v1.0.0/Nearby-Widget.md#add-nearby-widget)