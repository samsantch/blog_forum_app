# Blog Forum App

A Flutter blog/forum application with authentication, posts, comments, and multi-image upload, built on Supabase (Auth, Database, and Storage).

## Live Demo

**Live URL:** https://blog-forum-app.samuelconcepcion340.workers.dev

The post feed and individual posts are browsable without an account. Registration is required to create posts, comment, or upload images.

## Tech Stack

- **Flutter** — cross-platform UI (tested on web and Android)
- **Provider** — state management
- **go_router** — declarative routing, including a mix of public and protected routes
- **Supabase** — Authentication, Postgres Database with Row Level Security, and Storage

## Features

### Authentication
- Registration (email & password)
- Login / Logout
- Session persists across app restarts

### Posts
- Public post listing with pagination — **visible even when logged out**
- Create post with multiple image upload
- View post with images
- Update post — add and remove images independently
- Delete post

### Comments
- Full CRUD on comments, scoped to each post
- Multiple image upload on comments
- Delete individual comment images
- Only the comment's author can edit/delete it or its images

### Profile
- Profile photo upload, replace, and remove
- Username and bio update

## Architecture

The project follows a **feature-first** structure. Each feature (`auth`, `posts`, `comments`, `profile`) is self-contained, with three internal layers:

```
lib/
  core/                    # reusable widgets, services, theming — no business logic
    services/              # e.g. StorageService, shared across features
    widgets/                # e.g. AppButton, AppTextField, AppStateMessage
    theme/
  config/
    router/                 # centralized go_router configuration
    supabase_config.dart
  features/
    auth/
      data/                 # AuthRepository — only layer allowed to call Supabase directly
      logic/                # AuthProvider (ChangeNotifier)
      presentation/         # screens & widgets
    posts/
    comments/
    profile/
    shell/                  # bottom-nav shell composing posts + profile
```

**Key architectural decisions:**
- **Repository pattern** — each feature's `data/` layer is the *only* place allowed to talk to Supabase. UI and business logic never call Supabase directly. This keeps the app's business rules decoupled from the specific backend vendor.
- **Provider used where state is genuinely shared** — Auth and Posts use `ChangeNotifier`-based providers since multiple screens depend on the same data. Simpler screens (e.g. individual forms) use local state where no sharing is needed.
- **Row Level Security (RLS) as the real security boundary** — every table enforces ownership at the database level (e.g. `auth.uid() = author_id`). UI-level checks (like hiding an edit button) are a convenience, not the actual security mechanism.
- **Dependency injection for testability** — `AuthProvider` accepts its repository via constructor injection, allowing it to be unit tested with a mocked repository instead of hitting a real backend.

## Getting Started

```bash
git clone <this-repo-url>
cd blog_forum_app
flutter pub get
```

Create a file named `app.env` in the project root with:
```
SUPABASE_URL=your_supabase_project_url
SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
```

Then run:
```bash
flutter run
```

## Testing

```bash
flutter test
```

Includes unit tests for `AuthProvider` (using `mocktail` to mock repository dependencies) and widget tests for core reusable UI components.

## Known Limitations / Deliberate Scope Decisions

Documented explicitly rather than left implicit:

- **No real-time sync across devices/sessions.** Data updates locally based on the current user's own actions; another user's changes appear on next fetch (e.g. navigating back to the screen, or via pull-to-refresh), not instantly. Full live sync would require Supabase Realtime, which introduces meaningful complexity around merging live events with existing pagination and cached state — deliberately out of scope for this project's timeline.
- **Comment images can be added when creating a comment, and deleted at any time after, but not appended to an already-posted comment.** Matches how most platforms handle comment attachments and kept the inline-editing UI manageable.
- **Deleting a post or comment removes its database rows (including linked images, via cascading foreign keys) but does not delete the corresponding files from Supabase Storage.** Accepted as a minor, low-cost limitation for this project's scope.

## License

This project was built as a technical assessment submission.
