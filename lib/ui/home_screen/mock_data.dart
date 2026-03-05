// Mock JSON Data
const String mockJsonData = '''
{
  "home": {
    "sections": [
      {
        "type": "heroBanner",
        "data": {
          "title": "Welcome to Ocean View",
          "subtitle": "Experience Luxury by the Sea",
          "image": "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800",
          "cta": {
            "label": "Book Now",
            "route": "/rooms"
          }
        }
      },
      {
        "type": "highlights",
        "data": {
          "items": [
            {
              "icon": "wifi",
              "label": "Free WiFi"
            },
            {
              "icon": "pool",
              "label": "Swimming Pool"
            },
            {
              "icon": "restaurant",
              "label": "Restaurant"
            },
            {
              "icon": "local_parking",
              "label": "Free Parking"
            }
          ]
        }
      },
      {
        "type": "featuredRooms",
        "data": {
          "rooms": [
            {
              "id": "deluxe",
              "name": "Deluxe Room",
              "image": "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800"
            },
            {
              "id": "suite",
              "name": "Suite",
              "image": "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800"
            }
          ]
        }
      },
      {
        "type": "galleryPreview",
        "data": {
          "images": [
            "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800",
            "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800",
            "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800"
          ]
        }
      }
    ]
  }
}
''';
