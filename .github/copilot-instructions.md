# Copilot Instructions for Reactory Data

## Project Overview

Reactory Data is the data, assets, and CDN repository for the Reactory platform. It provides baseline directory structures, fonts, themes, internationalization files, client plugin source code and runtime bundles, email templates, workflow schedules, database backups, AI learning resources, and static content. This is **not** a typical application project -- there is no root-level `package.json` and no application code at the root level.

The server and client applications reference this directory at runtime via the `$REACTORY_DATA` and `$REACTORY_PLUGINS` environment variables.

## Directory Structure

```
reactory-data/
  builds/              # Uploaded build artifacts (gitignored content)
  content/             # Static HTML content served by StaticContent component
  database/            # Database backup scripts and dumps (PostgreSQL)
  fonts/               # ~257 font files (TTF, OTF) for server-side document generation
  forms/               # Form-related assets (images for form definitions)
  guideai/             # AI-powered learning/tutoring data (BookTutor)
    booktutor/         # Book library, learning paths, catalog, search index
  i18n/                # Internationalization translation files
    en/                # English translations
    en-US/             # US English translations
    af/                # Afrikaans translations
  imports/             # Import/data management staging area
  logging/             # Server log output (hourly JSON.gz files)
  nginx/               # Nginx configuration placeholder
  organization/        # Organization-specific data
  plugins/             # CLIENT PLUGINS (key workspace area)
    __runtime__/       # Runtime-compiled widget bundles (Rollup)
    artifacts/         # Published core package tarballs (.tgz)
    available.json     # Plugin registry
    graphiql/          # Embedded GraphiQL IDE
    libs/              # Shared libraries (Three.js)
    reactory-client-core/      # Core client plugin (React/Rollup)
    reactor-client/            # Reactor-specific client plugin
    reactor-system-navigator/  # 3D WebGL game/visualizer (Three.js)
  profiles/            # User avatars, AI persona data
    reactor/personas/  # 16 AI persona directories with avatars
  templates/           # Email templates (.ejs) and shell script templates
    email/defaults/    # Account activation and password reset templates
  themes/              # Application themes (images, styles.css per theme)
    reactory/          # Default theme
    booktutor/         # BookTutor theme
    zepz/              # Zepz theme
  tmp/                 # Temporary files
  wordnet/             # WordNet dictionary data for NLP features
  workflows/           # Workflow definitions and cron schedules (YAML)
    catalog/           # Versioned workflow definitions by namespace
    schedules/         # YAML cron schedule definitions
  www/                 # Web-served static files
```

## Plugin Architecture

### Plugin Naming Conventions
- **Plugin FQN**: `{namespace}.{PluginName}@{version}` (e.g., `client-core.RReactoryClientCore@1.0.0`)
- **Runtime widget source**: `source_{namespace}.{WidgetName}@{version}.tsx`
- **Runtime widget compiled**: `rollup.{namespace}.{WidgetName}@{version}.js`
- **Component registration**: `reactory.registerComponent(nameSpace, name, version, component)`

### Plugin Build System
Each plugin in `plugins/` has its own `package.json`, `tsconfig.json`, and `rollup.config.cjs`:
- Build tool: Rollup with Babel + TypeScript
- Output format: UMD
- React 17.0.2 as peer dependency
- MUI v5-v6 for UI components
- Target: ES2017-ES2018, module ESNext, JSX preserve

### Runtime Widgets (`plugins/__runtime__/`)
- Must run `npm install` in this directory before the server can compile widgets
- Source files and compiled bundles follow the naming conventions above

## Internationalization (i18n)

- Per-locale JSON files by namespace: `reactory.json`, `common.json`, `forms.json`, `reactor.json`, etc.
- Key format: `{namespace}.{context}.{key}` (e.g., `reactory.menu.documentation`)
- Only `*/reactory.json` files are tracked in git; others are gitignored

## Workflow Schedules

YAML files in `workflows/schedules/` define cron-based workflow schedules:
- Schema: `id`, `name`, `description`, `workflow` (id, version, nameSpace), `schedule` (cron, timezone, enabled), `properties`, `retry`, `timeout`, `maxConcurrent`
- Workflow reference format: `{namespace}.{WorkflowName}@{version}`

## Conventions

- **No application logic** at the root level -- this is a data store
- Organize assets by type and use readme files to describe folder contents
- Use `.gitignore` to avoid committing large, generated, or runtime files
- Reference assets from other projects using environment variables (`$REACTORY_DATA`, `$REACTORY_PLUGINS`)
- Add new assets in the correct subfolder
- Email templates use EJS templating (`.ejs` files)
- Themes contain `images/` directory and `styles.css`
- Fonts are used for server-side document generation (PDF, Excel)

## Environment Variables

```bash
REACTORY_DATA      # Path to this directory
REACTORY_PLUGINS   # Path to this directory's plugins/ subdirectory
```

## Important Notes

- Sub-projects within `plugins/` (like `reactory-client-core`, `reactor-system-navigator`) have their own `.git` repositories
- The `plugins/artifacts/` directory contains versioned `.tgz` tarballs of `@reactorynet/reactory-core`
- Most runtime and generated content is excluded from git -- only structural placeholders, i18n reactory.json files, default profiles, and plugin source code are tracked
