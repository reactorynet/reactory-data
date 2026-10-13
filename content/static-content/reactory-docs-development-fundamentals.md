# Development Fundamentals

Welcome to the core development guide for the **Reactory Platform**. Reactory is a high-velocity, modular, low-code application framework and AI-augmented runtime designed to take ideas to production with unprecedented speed, consistency, and reliability.

Whether you are building custom business applications, authoring automated backend workflows, or integrating specialized AI agents, understanding the fundamental principles of the Reactory architecture is essential.

---

## 1. Guiding Philosophy: High Velocity & Out-of-the-Box Power

Modern enterprise development often suffers from repetitive boilerplate—setting up authentication, role-based access control, CRUD interfaces, workflow orchestration, caching, and multi-tenant isolation. 

Reactory shifts the focus from repetitive infrastructure to immediate business value through:

- **Velocity First**: Rapidly test software assumptions with real users and fast deployment cycles.
- **Unified TypeScript Ecosystem**: A single language across server, client, plugins, workflows, and tools (`@reactorynet/reactory-core`).
- **Declarative & Schematic UX**: Build rich, dynamic forms and screens driven by JSON Schema (draft-07) and UI Schemas without manual UI code.
- **Pluggable Architecture**: Modular backend services and frontend plugins that snap together cleanly.
- **Integrated AI & Graph Engine**: First-class AI sub-agent orchestration backed by a real-time Neural System Graph.

---

## 2. Platform Architecture Overview

The Reactory platform is composed of distinct yet tightly cohesive layers:

```text
┌─────────────────────────────────────────────────────────────┐
│                    Reactory PWA Client                      │
│   • React + Material-UI (MUI v5)                            │
│   • Reactory SDK (`@reactory/client-core`)                  │
│   • Declarative Form Engine (JSON Schema + UI Schema)       │
│   • Dynamic Plugin & Component Registry                     │
│   • Client AMQ Event Bus                                    │
└──────────────────────────────┬──────────────────────────────┘
                               │ GraphQL / WebSocket / REST
┌──────────────────────────────▼──────────────────────────────┐
│                  Reactory Express Server                    │
│   • Modular Runtime Container (`@reactory/server-core`)     │
│   • GraphQL Gateway & Decorator-Driven Resolvers            │
│   • Reactory Workflow Engine (YAML & Code Workflows)        │
│   • Reactor AI Agent Orchestration & System Graph           │
│   • Multi-Tenant Partner & Application Context              │
└──────────────────────────────┬──────────────────────────────┘
                               │
       ┌───────────────────────┼───────────────────────┐
       ▼                       ▼                       ▼
 ┌───────────┐           ┌───────────┐           ┌───────────┐
 │  MongoDB  │           │ Relational│           │   Redis   │
 │ (Entities │           │ (Postgres/│           │ (Caching, │
 │  & State) │           │   MSSQL)  │           │ Pub/Sub)  │
 └───────────┘           └───────────┘           └───────────┘
```

### Core Subsystems:
1. **Reactory PWA Client**: A Progressive Web Application providing multi-tenant white-labeling, route guards, dynamic menu generation, and runtime component mounting.
2. **Reactory Express Server**: An extensible Node.js server powered by Express and Apollo Server, aggregating independently developed modules into a unified GraphQL API and service registry.
3. **Reactory Workflow Engine**: An asynchronous, resilient workflow engine that executes step pipelines declared in YAML or code.
4. **Reactor AI & System Graph**: AI agent orchestration with persistent memory, toolbelts, and a living knowledge graph indexing source files, database entities, and workflows.

---

## 3. Local Environment & Prerequisites

To develop on the Reactory platform, ensure your workstation meets the following requirements:

### Required Software
- **Node.js**: Version `18.x` or `20.x LTS` (Manage via `nvm` recommended).
- **Package Manager**: `yarn` (preferred) or `npm`.
- **Database Storage**:
  - **MongoDB**: Version 5.0+ (Required for core entities, forms, content, and system state).
  - **Redis**: Version 6.0+ (Required for cache acceleration and distributed locking).
  - **PostgreSQL / SQL Server**: Optional, depending on your project's relational database drivers.
- **Docker & Docker Compose**: Recommended for spinning up local instances of MongoDB, Redis, and auxiliary services.

### Environment Variables
The server relies on environment configuration files (`.env`):

```bash
# General Server Settings
PORT=4000
API_URI_ROOT=http://localhost:4000
NODE_ENV=development

# Storage Roots
APP_DATA_ROOT=/path/to/reactory-data
CONTENT_PATH=/path/to/reactory-data/content

# Database Connections
MONGO_URI=mongodb://localhost:27017/reactory
REDIS_HOST=localhost
REDIS_PORT=6379

# Security & Secrets
SECRET_KEY=your-secure-hex-string
JWT_SECRET=your-jwt-token-secret
```

---

## 4. Developer Quickstart & Monorepo Structure

The platform is structured into organized workspaces:

- `reactory-core`: Shared types, interfaces, utility functions, and foundational contracts.
- `reactory-express-server`: The backend Express server and module aggregator.
  - `src/modules/`: Pluggable server modules (`reactory-core`, `reactory-reactor`, etc.).
  - `src/data/clientConfigs/`: Per-client application configurations (routes, menus, themes, settings).
- `reactory-pwa-client`: The frontend React client.
  - `src/components/`: Core components, widgets, and form-engine renderers.
  - `src/api/`: Reactory SDK client and Apollo integration.
- `reactory-data`: Static content, templates, file uploads, and persistent runtime assets.

### Starting the Local Development Stack

1. **Start Backend Infrastructure**:
   ```bash
   # Using docker compose or native services
   docker compose up -d mongo redis
   ```

2. **Launch the Reactory Express Server**:
   ```bash
   cd reactory-express-server
   yarn install
   yarn dev:server
   ```
   *The server initializes on port 4000 and exposes the GraphiQL interactive playground at `http://localhost:4000/graphiql`.*

3. **Launch the Reactory PWA Client**:
   ```bash
   cd reactory-pwa-client
   yarn install
   yarn start
   ```
   *The client opens in your browser at `http://localhost:3000`.*

---

## 5. Coding Standards & Conventions

To maintain high code quality across distributed teams and automated AI workflows, adhere to the following standards:

1. **TypeScript Strictness**: Always provide explicit interfaces and avoid using bare `any` types wherever possible. Reference `@reactorynet/reactory-core` for platform types.
2. **Context Passing**: Server resolvers and services must always accept and inspect `Reactory.Server.IReactoryContext`. Never hardcode user permissions—use `context.hasRole()` or `@roles()` decorators.
3. **Decoupled Dependencies**: Modules should communicate via registered services (`context.getService('serviceId')`) or the event bus (AMQ), never through tight relative file couplings across modules.
4. **Resilient Error Handling**: Fail gracefully with actionable error logging (`context.log('Message', data, 'error')`).

---

## Next Steps

Now that you understand the foundational architecture and setup, dive deeper into specific layers:

- **[Module Development](/docs/development-server)**: Learn how to author backend modules, GraphQL resolvers, custom models, and services.
- **[Client Development](/docs/development-client)**: Explore PWA components, widgets, routing, and form integration.
- **[Styling & Theming](/docs/development-styling)**: Master Material-UI theming, custom palettes, dark mode, and component overrides.
