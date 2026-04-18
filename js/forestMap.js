// Leaflet Map for Forests
window.forestMapInterop = {
    map: null,
    markers: [],

    initializeMap: function (forests) {
        // Remove existing map if it exists
        if (this.map) {
            this.map.remove();
            this.map = null;
            this.markers = [];
        }

        // Initialize the map centered on Zambia
        this.map = L.map('forestsMap').setView([-13.1339, 27.8493], 6);

        // Add OpenStreetMap tile layer
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 18
        }).addTo(this.map);

        // Add markers for each forest
        if (forests && forests.length > 0) {
            forests.forEach(forest => {
                if (forest.latitude && forest.longitude) {
                    const color = this.getMarkerColor(forest.protectionStatus);
                    
                    // Create custom icon
                    const customIcon = L.divIcon({
                        className: 'custom-marker',
                        html: `<div style="background-color: ${color}; width: 24px; height: 24px; border-radius: 50%; border: 2px solid white; box-shadow: 0 2px 4px rgba(0,0,0,0.3);"></div>`,
                        iconSize: [24, 24],
                        iconAnchor: [12, 12]
                    });

                    // Create marker
                    const marker = L.marker([forest.latitude, forest.longitude], { icon: customIcon })
                        .addTo(this.map);

                    // Create popup content
                    const popupContent = `
                        <div style="min-width: 200px;">
                            <h3 style="margin: 0 0 10px 0; font-size: 16px; font-weight: 600;">${forest.name}</h3>
                            <div style="margin: 5px 0;">
                                <strong>Province:</strong> ${forest.province || 'N/A'}
                            </div>
                            <div style="margin: 5px 0;">
                                <strong>District:</strong> ${forest.district || 'N/A'}
                            </div>
                            <div style="margin: 5px 0;">
                                <strong>Size:</strong> ${forest.size ? forest.size.toLocaleString() + ' ha' : 'N/A'}
                            </div>
                            <div style="margin: 5px 0;">
                                <strong>Status:</strong> 
                                <span style="padding: 2px 8px; border-radius: 4px; background-color: ${color}; color: white; font-size: 12px;">
                                    ${forest.protectionStatus || 'Unknown'}
                                </span>
                            </div>
                            <div style="margin: 5px 0;">
                                <strong>Biodiversity:</strong> ${forest.biodiversityScore || 0}/100
                            </div>
                        </div>
                    `;

                    marker.bindPopup(popupContent);
                    this.markers.push(marker);
                }
            });

            // Fit map bounds to show all markers if there are any
            if (this.markers.length > 0) {
                const group = L.featureGroup(this.markers);
                this.map.fitBounds(group.getBounds().pad(0.1));
            }
        }

        // Force map to resize properly
        setTimeout(() => {
            if (this.map) {
                this.map.invalidateSize();
            }
        }, 100);
    },

    getMarkerColor: function (status) {
        switch (status) {
            case 'Fully Protected':
                return '#4CAF50';
            case 'Partially Protected':
                return '#FFC107';
            case 'At Risk':
                return '#F44336';
            default:
                return '#9E9E9E';
        }
    },

    destroyMap: function () {
        if (this.map) {
            this.map.remove();
            this.map = null;
            this.markers = [];
        }
    }
};
