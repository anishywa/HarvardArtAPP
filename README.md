# Harvard Art Museums iOS App

A SwiftUI app for browsing exhibitions and artworks from the Harvard Art Museums collection.

## Features

- **Browse Tab**: View a paginated list of exhibitions with images, titles, descriptions, and date ranges
- **Exhibition Detail**: Grid view of artworks within exhibitions with favorite functionality
- **Search Tab**: Search artworks by keyword with debounced API calls
- **Favorites Tab**: View favorited artworks grouped by exhibition
- **AI-Generated Overviews**: Get historical insights about artworks using Google's Gemini AI
- **Dark/Light Mode Support**: Fully supports iOS appearance modes
- **Pagination**: Infinite scroll with loading states for all list views

## Setup Instructions

### 1. Get API Keys

#### Harvard Art Museums API
1. Visit the [Harvard Art Museums API website](https://github.com/harvardartmuseums/api-docs)
2. Request an API key by following their documentation
3. You'll receive an API key via email

#### Google Gemini API (for AI overviews)
1. Visit [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Go to "Get API key" and create a new API key
4. Copy the generated API key

### 2. Configure API Keys

1. Copy the template file to create your secrets file:
   ```bash
   cp HarvardArtAPP/Support/Secrets.plist.template HarvardArtAPP/Support/Secrets.plist
   ```

2. Open `HarvardArtAPP/Support/Secrets.plist` and replace the placeholder values:
   ```xml
   <key>HAM_API_KEY</key>
   <string>your-harvard-art-museums-api-key-here</string>
   <key>GEMINI_API_KEY</key>
   <string>your-gemini-api-key-here</string>
   ```

**⚠️ Important**: The `Secrets.plist` file is gitignored to protect your API keys. Never commit real API keys to version control.

### 3. Build and Run

1. Open `HarvardArtAPP.xcodeproj` in Xcode
2. Select your target device or simulator (iOS 17.0+)
3. Build and run the project (⌘+R)

## Project Structure

```
HarvardArtAPP/
├── Models/                     # Data models
│   ├── Exhibition.swift
│   ├── Artwork.swift
│   ├── Person.swift
│   └── APIResponse.swift
├── Networking/                 # API layer
│   └── APIClient.swift
├── Features/                   # Feature modules
│   ├── Browse/
│   │   ├── BrowseView.swift
│   │   └── BrowseViewModel.swift
│   ├── ExhibitionDetail/
│   │   ├── ExhibitionDetailView.swift
│   │   └── ExhibitionDetailViewModel.swift
│   ├── Search/
│   │   ├── SearchView.swift
│   │   └── SearchViewModel.swift
│   └── Favorites/
│       └── FavoritesView.swift
├── Persistence/                # Data persistence
│   └── FavoritesStore.swift
└── Support/                    # Configuration
    └── Secrets.plist
```

## Architecture

- **MVVM Pattern**: Each view has a corresponding view model for business logic
- **Async/Await**: Modern concurrency for API calls
- **Combine**: Used for reactive UI updates with @Published properties
- **UserDefaults**: Simple persistence for favorites (JSON encoded)
- **Environment Objects**: Shared state management for favorites across tabs

## API Integration

The app integrates with the Harvard Art Museums API:

- **Base URL**: `https://api.harvardartmuseums.org`
- **Exhibitions**: `/exhibition?apikey=KEY&size=20&page=1`
- **Artworks in Exhibition**: `/object?apikey=KEY&exhibition=ID&hasimage=1`
- **Search Artworks**: `/object?apikey=KEY&q=QUERY&hasimage=1`

All endpoints support pagination and the app implements infinite scroll.

## Key Features Implementation

### Favorites System
- Favorites are stored locally using UserDefaults
- Each favorited artwork remembers which exhibition it was favorited from
- Favorites are grouped by exhibition in the Favorites tab
- Heart animation with spring physics on toggle

### Search with Debouncing
- 300ms debounce to prevent excessive API calls
- Real-time search as user types
- Cancels previous requests when new search is initiated

### Error Handling
- Graceful handling of network errors
- User-friendly error messages
- Retry functionality for failed requests

### Loading States
- Skeleton loading for initial loads
- Pull-to-refresh on all list views
- Loading indicators for pagination

## Known Limitations

1. **Search Context**: Search results don't have specific exhibition context, so they're grouped under "Search Results" in favorites
2. **Image Caching**: Uses basic AsyncImage without advanced caching (could be improved with SDWebImage or similar)
3. **Offline Support**: No offline functionality - requires internet connection

## Next Steps

If given more time, these improvements could be added:

1. **Enhanced Image Caching**: Implement NSCache or third-party solution
2. **Core Data Integration**: More robust persistence with relationships
3. **Detail View**: Full-screen artwork detail view with zoom capability
4. **Share Functionality**: Share artworks via system share sheet
5. **Accessibility**: Enhanced VoiceOver support and dynamic type
6. **Unit Tests**: Comprehensive test coverage for ViewModels and API client
7. **Haptic Feedback**: Tactile feedback for heart toggles and interactions

## Requirements Compliance

✅ **3-tab app** with Browse (default), Search, and Favorites  
✅ **Harvard Art Museums API** integration with pagination  
✅ **Secrets.plist** for API key management  
✅ **Exhibition browsing** with image, title, description, date range  
✅ **Exhibition detail** with artwork grid and heart favorites  
✅ **Search functionality** with debounced queries  
✅ **Favorites grouping** by exhibition  
✅ **Light/Dark mode** support  
✅ **Loading/Error/Empty states** throughout  
✅ **Native SwiftUI** for iOS 17+  
✅ **Production-quality code** with proper architecture  

## API Key Security Note

The `Secrets.plist` file should not be committed to version control in a production environment. Consider using:

- Xcode build configurations
- Environment variables
- CI/CD secret management
- Keychain services for production apps
