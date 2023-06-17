#!/bin/bash

# Read the input JSON from a file or stdin
if [ -n "$1" ]; then
    json=$(cat "$1")
else
    json=$(cat)
fi

# Extract the necessary information from the JSON
features=$(echo "$json" | jq -r '.results[] | {
    "type": "Feature",
    "geometry": {
        "type": "Point",
        "coordinates": [.position.lon, .position.lat]
    },
    "properties": {
        "id": .id,
        "name": .poi.name,
        "phone": .poi.phone,
        "url": .poi.url,
        "categories": .poi.categories,
        "address": .address.freeformAddress,
        "streetName": .address.streetName,
        "streetNumber": .address.streetNumber,
        "postalCode": .address.postalCode,
        "city": .address.municipality,
        "country": .address.country,
        "entryPoints": [.entryPoints[] | {
            "type": .type,
            "coordinates": [.position.lon, .position.lat]
        }],
        "viewport": {
            "topLeftPoint": [.viewport.topLeftPoint.lon, .viewport.topLeftPoint.lat],
            "bottomRightPoint": [.viewport.btmRightPoint.lon, .viewport.btmRightPoint.lat]
        }
    }
}' | jq --slurp '.')

# Extract the summary from the JSON
summary=$(echo "$json" | jq -r '.summary')

# Create the GeoJSON object
geojson=$(jq -n --argjson features "$features" --argjson summary "$summary" '{
    "type": "FeatureCollection",
    "features": $features,
    "summary": $summary
}')

# Print the resulting GeoJSON
echo "$geojson"
