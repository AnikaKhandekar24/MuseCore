# MuseCore

MuseCore is a student portfolio music app with a pastel SwiftUI frontend and a Python FastAPI backend. The app recommends songs from a local JSON song database using mood, favorite genres, energy level, time of day, recently played songs, and skipped songs.

## Features

- SwiftUI iOS app with a clean pastel interface
- FastAPI backend with modular recommendation logic
- JSON song database with sample songs
- Mood-based playlist generation
- Personalized recommendations
- Favorites system
- Listening history tracking
- Music insights dashboard with top mood, top genre, total plays, favorites, and most-played songs
- API connection from SwiftUI to Python

## Project Structure

```text
MuseCore/
  backend/
    main.py
    recommender.py
    database.py
    models.py
    sample_songs.json
    requirements.txt
  ios/
    project.yml
    MuseCore/
      MuseCoreApp.swift
      Info.plist
      Components/
      Models/
      Services/
      Theme/
      ViewModels/
      Views/
  README.md
```

## Backend Setup

From the project root:

```bash
cd backend
python -m venv .venv
```

Activate the virtual environment.

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

macOS or Linux:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the API:

```bash
uvicorn main:app --reload
```

Open the API docs:

```text
http://127.0.0.1:8000/docs
```

## API Endpoints

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/songs` | Returns all songs |
| POST | `/recommend` | Returns personalized song recommendations |
| POST | `/mood-playlist` | Creates a mood-based playlist |
| GET | `/favorites` | Returns favorited songs |
| POST | `/favorites` | Adds or removes a favorite |
| GET | `/history` | Returns recently played songs |
| POST | `/history` | Tracks a play or skip |
| GET | `/insights` | Returns dashboard statistics |

## Recommendation Logic

The recommender scores each song using:

- Selected mood
- Related moods
- Favorite genres
- Energy level
- Time of day
- Study-friendly preference for calm/focused moods
- Play count
- Recently played songs
- Skipped songs
- Existing favorites

The logic is intentionally readable and beginner-friendly, so it is easy to explain in a portfolio presentation.

## SwiftUI App Setup

The SwiftUI source lives in `ios/MuseCore`.

### Option 1: Open with XcodeGen

If you have XcodeGen installed:

```bash
cd ios
xcodegen generate
open MuseCore.xcodeproj
```

Then run the app on an iOS Simulator.

### Option 2: Create a New Xcode Project Manually

1. Open Xcode.
2. Create a new iOS App project named `MuseCore`.
3. Choose SwiftUI for the interface.
4. Copy the folders inside `ios/MuseCore` into the Xcode project.
5. Make sure the files are added to the app target.
6. Run the FastAPI backend.
7. Run the iOS app in the simulator.

## Connecting SwiftUI to FastAPI

The API base URL is in:

```text
ios/MuseCore/Services/APIService.swift
```

For the iOS Simulator, this value should work:

```swift
http://127.0.0.1:8000
```

For a physical iPhone, replace it with your computer's local network IP address, for example:

```swift
http://192.168.1.12:8000
```

When using a physical phone, run the backend with:

```bash
uvicorn main:app --reload --host 0.0.0.0
```

## Portfolio Demo Flow

1. Start on the Welcome screen.
2. Open Home to show recommendations.
3. Pick a mood on the Mood Picker screen.
4. Open the generated Playlist.
5. Play, skip, and favorite songs.
6. Open Favorites to show saved songs.
7. Open Music Insights to show top mood, top genre, favorites, total plays, and most-played songs.

## Notes

- Song data is stored in `backend/sample_songs.json`.
- Favorites and play counts are written back to the JSON file.
- Listening history is kept in memory while the backend server is running.
- The backend is intentionally modular: API routes, data access, models, and recommendation logic each have their own file.
