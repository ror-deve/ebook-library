# Digital Ebook Library Application

## Project Overview
This project is an end-to-end Digital Ebook Library that allows users to seamlessly upload, manage, search, read, download, and delete ebooks. It features a modern, visually striking bookshelf UI inspired by the older iOS iBooks application, where books dynamically display their information right on colored covers that sit atop wooden shelves.

## Tech Stack
- **Backend:** Ruby on Rails 8 (API-only mode), PostgreSQL
- **Frontend:** Flutter (Linux desktop target, plus mobile/web compatibility)
- **State Management:** Provider
- **Storage:** Active Storage (Local Disk configured for API access)

## Setup Instructions

### Prerequisites
- Ruby 3+ & Rails 8
- PostgreSQL installed and running
- Flutter SDK (with Linux desktop build tools like `cmake`, `ninja-build`, `libgtk-3-dev`)

> **Note:** The Rails backend must be running *before* starting the Flutter app — the app makes live API calls on startup and will show connection errors otherwise.

### 1. Backend (Ruby on Rails)
Navigate to the rails folder:
```bash
cd ebook_library
```
Install dependencies and set up the database:
```bash
bundle install
rails db:create db:migrate
```
> This assumes a local Postgres role with no password, matching the defaults in `config/database.yml`. If your local Postgres setup uses a different username/password, update `config/database.yml` accordingly before running the commands above.

Start the server (must be run on port 3000 to match the Flutter app config):
```bash
rails server -p 3000
```

### 2. Frontend (Flutter)
Open a new terminal and navigate to the flutter folder:
```bash
cd ebook_library_app
```
Install dependencies:
```bash
flutter pub get
```
Run the application:
```bash
flutter run -d linux
```
> If Linux desktop build tools aren't available on your machine, run it in Chrome instead as a fallback:
> ```bash
> flutter run -d chrome
> ```

## How to Run Tests

### Backend Tests (RSpec)
We have comprehensive request specs checking all REST endpoints, validation errors, and file uploads.
```bash
cd ebook_library
bundle exec rspec
```

### Frontend Tests (Flutter)
Widget tests cover library screen rendering, empty states, and card display.
```bash
cd ebook_library_app
flutter test
```

## Manual Testing Checklist
- [ ] **Upload Flow**: Click the floating action button (+), select a valid PDF, enter metadata, and upload. Ensure it appears instantly in the grid.
- [ ] **Fail Upload**: Try uploading without a PDF to see the correct validation snackbar error.
- [ ] **Reader Flow**: Tap an uploaded book to open the full-screen reader. Verify PDF scrolling.
- [ ] **Empty State Reader**: Tap a book that purposely has no PDF attachment and verify the clear "No PDF attached" fallback screen appears.
- [ ] **Download Flow**: Inside the reader, click the top right download icon and ensure it launches the system browser/downloader to save the PDF.
- [ ] **Search**: Use the top-right search icon to type a query, verify instantaneous debounced filtering of books.
- [ ] **Delete**: Click the trash icon on the top right of a book card. Cancel the dialog to abort, then click Delete to ensure it vanishes from the UI and backend.

## API Overview
- `GET /api/ebooks` - Returns list of all ebooks sorted by newest. Includes dynamic `file_url`.
- `POST /api/ebooks` - Upload an ebook via multipart form-data.
- `GET /api/ebooks/:id` - Show single book details.
- `DELETE /api/ebooks/:id` - Deletes ebook and purges attached files.
- `GET /api/ebooks/:id/download` - Provides strict download headers for the physical file.
- `GET /api/ebooks/search?q=keyword` - Performs an `ILIKE` case-insensitive query across titles and authors.

## Known Limitations
- The app currently does not possess built-in authentication, leaving it open to the public as per the MVP instructions.
- File sizes are strictly limited to `50MB`. (Files above this will be rejected by the backend)
- While the rails backend supports `cover_image` attachment logic in the controller, it was deliberately deferred from the Flutter UI to maintain visual simplicity and focus on the clean dynamically-colored covers. (Linux `file_picker` quirks with some mime-types required custom backend octet-stream overrides).
- **EPUB is not supported in this submission** — only PDF upload and reading are implemented, per the assignment's minimum requirement. EPUB was deferred given the 2-day timeline.
- The Flutter app's API base URL is hardcoded to `http://localhost:3000`, assuming the backend and frontend run on the same machine (true for `-d linux` and `-d chrome`). Running on a physical device or emulator with separate networking would require this to be made configurable.

## AI Tools Usage Statement
During development, AI assistants (like Claude/Cursor/Gemini) were actively utilized as engineering partners to:
- **Scaffold the API:** AI helped generate standard Rails RSpec testing data to verify all edge cases before UI construction.
- **Architect Flutter State:** Guided the usage of `Provider` to avoid messy setState prop drilling.
- **Debug Build Issues:** AI was actively referenced when debugging deeply cached CMake path issues on Linux and tracking down the `.platform` syntax changes in the `file_picker` v11 dependency.
- **UI Polish:** Iterated on the "Wooden Bookshelf" layout to perfectly align contiguous shelving without using external image assets, using `GridView` and `Stack`.

Manual reviews were consistently performed on AI output to ensure `file_url` injection didn't break JSON serialization and to confirm smooth user/error handling (for instance, catching exception overrides in the Provider instead of accidentally blanking out the main UX). One notable example of manual cleanup: an earlier AI-generated draft had left duplicate, unused copies of the `Ebook` model and `ApiService` sitting flat in `lib/` after the code was refactored into `models/` and `services/` folders — these dead files were identified via import tracing and removed before submission.