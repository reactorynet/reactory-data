# Reactory Data -- Agent Context

## What Is This Project

Reactory Data (`reactory-data`) is the data, assets, and CDN repository for the Reactory platform. It provides baseline directory structures, fonts, themes, internationalization files, client plugin source code and runtime bundles, email templates, workflow schedules, database backups, AI learning resources, and static content.

This is **not** a typical application project. There is no root-level `package.json` and no application code at the root level. The Reactory server and client applications reference this directory at runtime via the `$REACTORY_DATA` and `$REACTORY_PLUGINS` environment variables.

## Directory Structure

```
reactory-data/
  builds/                        # Uploaded build artifacts (gitignored)
  content/                       # Static HTML content served by StaticContent component
  database/                      # Database backup scripts and dumps
    backups/                     # Backup files
    pg17_backup.sh               # PostgreSQL 17 backup script
  fonts/                         # ~257 font files (TTF, OTF, FON, TTC)
                                 # Used for server-side document generation (PDF, Excel)
  forms/                         # Form-related assets (images for form definitions)
    images/
  guideai/                       # AI-powered learning/tutoring data
    booktutor/
      library/                   # Book catalog, search index, books in Markdown
      learning-paths/            # Learning path definitions
      progress/                  # Student progress tracking
      resources/                 # Educational resources
  i18n/                          # Internationalization translation files
    en/                          # English translations
    en-US/                       # US English translations
    af/                          # Afrikaans translations
  imports/                       # Import/data staging area
  logging/                       # Server log output (hourly JSON.gz files)
  nginx/                         # Nginx configuration placeholder
  organization/                  # Organization-specific data
  plugins/                       # CLIENT PLUGINS -- key workspace area (see below)
    __runtime__/                 # Runtime-compiled widget bundles
    artifacts/                   # Published core package tarballs (.tgz)
    available.json               # Plugin registry of installable plugins
    graphiql/                    # Embedded GraphiQL IDE
    libs/                        # Shared libraries (Three.js distribution)
    reactory-client-core/        # Core client plugin (React components, Rollup)
    reactor-client/              # Reactor-specific client plugin
    reactor-system-navigator/    # 3D WebGL game/visualizer (Three.js, standalone app)
  profiles/                      # User avatars and AI persona data
    default/                     # Default avatar (default.png)
    reactory/                    # Reactory bot avatar
    reactor/
      personas/                  # 16 AI persona directories with avatars
      macros/                    # Macro definitions
      projects/                  # Project definitions
      tools/                     # Tool definitions
  templates/                     # Template files
    email/
      defaults/
        activation/              # Account activation email templates (.ejs)
        forgot/                  # Password reset email templates (.ejs)
    shell/                       # Shell script templates
  themes/                        # Application themes
    reactory/                    # Default theme (images/, styles.css, asciilogo.txt)
    booktutor/                   # BookTutor theme
    socialeyes/                  # SocialEyes theme
    zepz/                        # Zepz theme
  tmp/                           # Temporary files
  wordnet/                       # WordNet dictionary data for NLP features
    dict/                        # Full WordNet lexical database
  workflows/                     # Workflow definitions and schedules
    catalog/                     # Versioned workflow definitions by namespace
    schedules/                   # YAML cron schedule definitions
    assets/                      # Workflow assets
    config/                      # Workflow configuration
  www/                           # Web-served static files
```

## Plugin Architecture

### Overview

The `plugins/` directory is the most complex area. It contains independently buildable TypeScript/React plugin projects and the runtime compilation workspace.

### Plugin Naming Conventions

- **Plugin FQN**: `{namespace}.{PluginName}@{version}` (e.g., `client-core.RReactoryClientCore@1.0.0`)
- **Runtime widget source files**: `source_{namespace}.{WidgetName}@{version}.tsx`
- **Runtime widget compiled bundles**: `rollup.{namespace}.{WidgetName}@{version}.js`
- **Component registration**: `reactory.registerComponent(nameSpace, name, version, component)`

### Plugin Projects

1. **`plugins/__runtime__/`** -- Runtime widget compilation workspace
   - Package: `@reactory/runtime-plugins`
   - Build: Rollup + Babel + TypeScript
   - **Must run `npm install` before the server can compile widgets**
   - Contains source `.tsx` and compiled `.js` bundles

2. **`plugins/reactory-client-core/`** -- Core client plugin (has its own `.git`)
   - Package: `@reactory/client-core-plugin`
   - Build: Rollup (`rollup.config.cjs`), outputs to `lib/reactory.client.core.js`
   - Components: Authentication, Develop, Froala, Organization, ReactoryClient, TemplateEditors, User

3. **`plugins/reactor-client/`** -- Reactor-specific client plugin
   - Custom components in `src/components/`

4. **`plugins/reactor-system-navigator/`** -- Standalone 3D game/visualizer (has its own `.git`)
   - Package: `reactor-system-navigator`
   - Tech: Three.js, TypeScript, Express, Jest, Inversify
   - ESM module, runs with `node server.js`

5. **`plugins/artifacts/`** -- Published core package tarballs
   - Contains versioned `.tgz` files of `@reactorynet/reactory-core`

### Plugin Build System

Each plugin has its own `package.json`, `tsconfig.json`, and `rollup.config.cjs`:
- Build tool: Rollup with Babel + TypeScript
- Output format: UMD
- React 17.0.2 as peer dependency
- MUI v5-v6 for UI components
- TypeScript target: ES2017-ES2018, module ESNext, JSX preserve
- Node version: 20.19.4 (`.nvmrc`)

## Internationalization (i18n)

- **Locales**: `en`, `en-US`, `af` (Afrikaans)
- **File format**: JSON, one file per namespace per locale
- **Namespace files**: `reactory.json`, `common.json`, `forms.json`, `reactor.json`, `booktutor.json`, `zepz-engineer.json`, `socialeyes.json`, `zepz.json`
- **Key format**: `{namespace}.{context}.{key}` (e.g., `reactory.menu.documentation`, `support-ticket.model.status.new`)
- **Git tracking**: Only `*/reactory.json` files are tracked; others are gitignored

## Workflow Schedules

YAML files in `workflows/schedules/` define cron-based workflow execution:

```yaml
id: "unique-id"
name: "Schedule Name"
description: "What this schedule does"
workflow:
  id: "workflow-id"
  version: "1.0.0"
  nameSpace: "namespace"
schedule:
  cron: "0 */1 * * *"
  timezone: "UTC"
  enabled: true
properties: {}
retry: { maxAttempts: 3, delay: 5000 }
timeout: 300000
maxConcurrent: 1
```

Workflow reference format: `{namespace}.{WorkflowName}@{version}`

## Theme Structure

Each theme directory contains:
- `images/` -- Theme-specific images (logos, backgrounds)
- `styles.css` -- Theme-specific CSS
- The `reactory` theme also includes `asciilogo.txt`

## Email Templates

- Located in `templates/email/defaults/`
- Use **EJS templating** (`.ejs` files)
- Organized by function: `activation/` (account activation), `forgot/` (password reset)

## Conventions

- **No application logic** at the root level -- this is a data store
- Organize assets by type in the correct subdirectory
- Use readme files to describe folder contents
- Use `.gitignore` to exclude large, generated, or runtime files
- Reference assets from other projects using `$REACTORY_DATA` and `$REACTORY_PLUGINS`
- Sub-projects in `plugins/` have their own `.git` repositories

## Environment Variables

```bash
REACTORY_DATA      # Path to this directory
REACTORY_PLUGINS   # Path to this directory's plugins/ subdirectory
```

## Git Tracking Notes

Most runtime and generated content is excluded from git. What IS tracked:
- Directory structure placeholders (readme files)
- i18n `reactory.json` files (other namespace translations are gitignored)
- Default profiles and organizations
- Plugin source code
- Theme files, font files, email templates
- Workflow schedules and catalog definitions
