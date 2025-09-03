# Harvard Art Museums iOS App - Testing Checklist

## 🔧 **Pre-Testing Setup**
- [ ] API key is properly configured in `Secrets.plist`
- [ ] App builds without errors in Xcode
- [ ] Device/Simulator has internet connection
- [ ] iOS 17+ target device/simulator selected

---

## 📱 **App Launch & Navigation**

### Initial Launch
- [ ] App launches without crashing
- [ ] Tab bar is visible with 3 tabs: Browse, Search, Favorites
- [ ] Browse tab is selected by default
- [ ] Tab icons display correctly (building.columns, magnifyingglass, heart)

### Tab Navigation
- [ ] Tapping Browse tab shows exhibitions list
- [ ] Tapping Search tab shows search interface
- [ ] Tapping Favorites tab shows favorites (empty initially)
- [ ] Tab switching is smooth without delays
- [ ] Navigation titles display correctly

---

## 🏛️ **Browse Tab Testing**

### Initial Load
- [ ] Loading indicator appears on first load
- [ ] Exhibitions load and display in list format
- [ ] Each exhibition row shows:
  - [ ] Exhibition image (or gray placeholder)
  - [ ] Exhibition title
  - [ ] Description (2-3 lines, truncated)
  - [ ] Date range (Begin - End format)

### Exhibition List Interactions
- [ ] Pull-to-refresh works and reloads data
- [ ] Scrolling to bottom triggers pagination (loading more)
- [ ] "Loading more" indicator appears during pagination
- [ ] Tapping an exhibition navigates to detail view
- [ ] Back navigation from detail works correctly

### Error Handling
- [ ] Network error shows proper error alert
- [ ] "Try Again" button works in empty state
- [ ] Error alert can be dismissed with "OK"
- [ ] App recovers gracefully from errors

---

## 🖼️ **Exhibition Detail Testing**

### Navigation & Layout
- [ ] Detail view shows exhibition title in navigation bar
- [ ] Large navigation title displays correctly
- [ ] Grid layout shows 2 columns of artworks
- [ ] Only artworks with images are displayed

### Artwork Cards
- [ ] Each artwork card shows:
  - [ ] Artwork image (or gray placeholder)
  - [ ] Artwork title
  - [ ] Artist name (or "Unknown Artist")
  - [ ] Date created
  - [ ] Description/label text (truncated)
  - [ ] Heart icon (outline initially)

### Favorites Functionality
- [ ] Tapping heart icon toggles favorite state
- [ ] Heart animates with spring effect when tapped
- [ ] Heart fills red when favorited
- [ ] Heart empties when unfavorited
- [ ] Favorite state persists when navigating away/back
- [ ] Multiple artworks can be favorited

### Pagination & Refresh
- [ ] Pull-to-refresh works in detail view
- [ ] Scrolling to bottom loads more artworks
- [ ] Loading indicator shows during pagination
- [ ] Empty state shows if no artworks available

---

## 🔍 **Search Tab Testing**

### Search Interface
- [ ] Search bar is prominently displayed at top
- [ ] Placeholder text: "Search for artworks"
- [ ] Search icon appears in search field
- [ ] "Clear" button appears when typing

### Search Functionality
- [ ] Typing triggers debounced search (300ms delay)
- [ ] Search results display in 2-column grid
- [ ] Results show same artwork card layout as detail view
- [ ] Empty search shows "Search for artworks" state
- [ ] No results shows "No results found" state

### Search Interactions
- [ ] Tapping search bar allows text input
- [ ] Submitting search (return key) triggers search
- [ ] Clear button empties search and clears results
- [ ] Search works for various queries:
  - [ ] Artist names (e.g., "Van Gogh")
  - [ ] Artwork titles (e.g., "Starry Night")
  - [ ] General terms (e.g., "painting")

### Search Favorites
- [ ] Heart icons work in search results
- [ ] Favorited search items appear in Favorites tab
- [ ] Search-favorited items grouped under "Search Results"

---

## ❤️ **Favorites Tab Testing**

### Empty State
- [ ] Shows heart icon when empty
- [ ] Displays exact text: "You have no favorited artwords"
- [ ] Shows descriptive subtitle about favoriting

### Favorites Display
- [ ] Favorited artworks appear grouped by exhibition
- [ ] Section headers show exhibition names
- [ ] Each favorite shows:
  - [ ] Small thumbnail image
  - [ ] Artwork title
  - [ ] Artist name
  - [ ] Date
  - [ ] Description (2 lines max)
  - [ ] Red filled heart icon

### Favorites Management
- [ ] Tapping heart removes from favorites
- [ ] Removal animates smoothly
- [ ] Empty sections disappear when last item removed
- [ ] Returns to empty state when all favorites removed
- [ ] Favorites persist after app restart

---

## 🔄 **Data Persistence Testing**

### App Lifecycle
- [ ] Favorites persist after app backgrounding
- [ ] Favorites persist after app termination/restart
- [ ] No duplicate favorites when toggling rapidly
- [ ] Favorites maintain exhibition grouping correctly

### Data Integrity
- [ ] Favorite artwork data displays correctly
- [ ] Images load properly for favorited items
- [ ] Exhibition context preserved for each favorite

---

## 🌓 **Appearance & Accessibility**

### Dark/Light Mode
- [ ] App works correctly in Light mode
- [ ] App works correctly in Dark mode
- [ ] Switching modes updates UI properly
- [ ] All text remains readable in both modes
- [ ] Images and icons display correctly in both modes

### Dynamic Type
- [ ] Text scales with system font size settings
- [ ] Layout adjusts properly with larger text
- [ ] No text gets cut off at larger sizes

### Accessibility
- [ ] VoiceOver can navigate all elements
- [ ] Images have appropriate accessibility labels
- [ ] Buttons have descriptive accessibility labels
- [ ] Heart toggle states are announced properly

---

## 📱 **Device & Orientation Testing**

### Device Compatibility
- [ ] Works on iPhone (various sizes)
- [ ] Works on iPad (if supported)
- [ ] Adapts to different screen sizes properly

### Orientation
- [ ] Portrait orientation works correctly
- [ ] Landscape orientation (if supported) works
- [ ] Grid layouts adapt to orientation changes

---

## 🚫 **Error Scenarios Testing**

### Network Issues
- [ ] No internet connection shows appropriate error
- [ ] Slow connection doesn't crash app
- [ ] Network timeout handled gracefully
- [ ] App recovers when connection restored

### API Issues
- [ ] Invalid API key shows clear error message
- [ ] API rate limiting handled appropriately
- [ ] Server errors (5xx) show user-friendly messages
- [ ] Malformed responses don't crash app

### Edge Cases
- [ ] Very long exhibition/artwork titles display properly
- [ ] Missing images show gray placeholders
- [ ] Empty API responses handled correctly
- [ ] Rapid tab switching doesn't cause issues

---

## ⚡ **Performance Testing**

### Loading Performance
- [ ] Initial app launch is reasonably fast
- [ ] Image loading doesn't block UI
- [ ] Smooth scrolling in all list views
- [ ] No memory leaks during extended use

### Memory Usage
- [ ] App doesn't consume excessive memory
- [ ] Memory usage stable during normal operation
- [ ] No crashes during extended testing sessions

---

## 🔧 **Final Verification**

### Core Requirements Met
- [ ] ✅ 3-tab app structure (Browse, Search, Favorites)
- [ ] ✅ Harvard Art Museums API integration
- [ ] ✅ Exhibitions browsing with pagination
- [ ] ✅ Exhibition detail with artwork grid
- [ ] ✅ Search functionality with debouncing
- [ ] ✅ Favorites system with persistence
- [ ] ✅ Proper error handling throughout
- [ ] ✅ Loading states for all async operations
- [ ] ✅ Dark/Light mode support
- [ ] ✅ Native SwiftUI implementation

### User Experience
- [ ] App feels responsive and smooth
- [ ] Navigation is intuitive
- [ ] Visual design is consistent
- [ ] Error messages are helpful
- [ ] Loading states provide good feedback

---

## 📝 **Testing Notes**

**Test Environment:**
- iOS Version: ___________
- Device/Simulator: ___________
- API Key Status: ___________
- Date Tested: ___________

**Issues Found:**
- [ ] Issue 1: _________________________
- [ ] Issue 2: _________________________
- [ ] Issue 3: _________________________

**Overall Assessment:**
- [ ] ✅ Ready for submission
- [ ] ⚠️ Minor issues to address
- [ ] ❌ Major issues need fixing

---

**Tester Signature:** _________________ **Date:** _________
