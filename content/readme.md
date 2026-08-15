# Reactory Static Content & Default Ingestion

This directory (`${APP_DATA_ROOT}/content/static-content`) hosts fallback and default static content files served by `ReactoryContentService` (`core.ReactoryContentService@1.0.0`).

When a client or component (such as the `<StaticContent />` component) requests content by `slug`, the server follows a structured ingestion pipeline:

---

## 1. Resolution & Fallback Pipeline

1. **MongoDB Database Lookup**:
   - The service queries MongoDB (`reactory_content` collection) for an existing document with matching `{ slug }`.
   - If found, the database document is returned directly.

2. **Disk Static Content Fallback**:
   - If no database record exists, the server checks `${APP_DATA_ROOT}/content/static-content/` for local content files matching the requested `slug`.

---

## 2. File Resolution Order & Locale Precedence

When looking up files on disk for a given `slug`, the service resolves the active user language (`lang = context.i18n.language.toLowerCase()`) and evaluates files in the following strict order of precedence:

| Priority | File Pattern | Format | Description |
|---|---|---|---|
| 1 | `${slug}.${lang}.html` | HTML | Locale-specific HTML content |
| 2 | `${slug}.html` | HTML | Default HTML content |
| 3 | `${slug}.${lang}.md` | Markdown | Locale-specific Markdown content |
| 4 | `${slug}.md` | Markdown | Default Markdown content |

The first matching file found is read into memory as the main content body.

---

## 3. Metadata & Sidecar Properties (`.props.json`)

You can provide a JSON sidecar file alongside your content file to supply additional metadata fields (e.g., `title`, `description`, `topics`, `roles`, `createdBy`).

Properties resolution order:
1. `${slug}.${lang}.props.json` (Locale-specific properties)
2. `${slug}.props.json` (Default properties)

### Example Properties File (`about-reactory.props.json`):
```json
{
  "title": "About Reactory Platform",
  "description": "An overview of the Reactory low-code application development platform.",
  "topics": ["reactory", "platform", "overview"],
  "roles": ["USER", "ANON"],
  "createdBy": {
    "email": "system@reactory.net"
  }
}
```

---

## 4. Default Content Object Schema

When loaded from disk, `ReactoryContentService` constructs an `IReactoryContent` object with the following defaults:

- `slug`: The requested content slug
- `content`: File string content (HTML or Markdown)
- `title`: Defaults to `slug` (overridden by `props.title`)
- `published`: `true`
- `createdAt`: `new Date()`
- `createdBy`: System partner user or `props.createdBy.email` resolved user
- `updatedAt`: `new Date()`
- `updatedBy`: System partner user or `props.createdBy.email` resolved user
- `...props`: Merged attributes from `.props.json`

---

## 5. Example Directory Layout

```text
reactory-data/content/static-content/
├── about-reactory.md
├── about-reactory.props.json
├── about-reactory.fr.md
├── terms-and-conditions.html
└── terms-and-conditions.props.json
```
