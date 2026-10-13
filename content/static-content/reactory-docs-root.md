# Reactory Platform Documentation

Welcome to the **Reactory Platform Developer Documentation**. Reactory is an enterprise-grade, modular low-code framework and AI-augmented runtime designed for rapid full-stack application development, workflow automation, and agent orchestration.

Explore the core sections below to learn how to build, extend, and style applications on Reactory:

---

## 📚 Core Development Guides

### 1. [Development Fundamentals](/docs/development-fundamentals)
Discover the fundamental architecture, prerequisites, local environment setup, monorepo layout, and developer workflows that power Reactory.
- Architecture overview: PWA Client, Express Server, AI & Workflow Engine
- Local environment setup with Node.js, MongoDB, and Redis
- Developer tooling, CLI scripts, and standards

### 2. [Module Development](/docs/development-server)
Learn how to build self-contained backend server modules for the Reactory Express Server.
- Understanding `IReactoryModule` and module directory structure
- Authoring GraphQL schemas and decorator-driven resolvers (`@resolver`, `@query`, `@mutation`, `@roles`)
- Creating injected domain services and data persistence models
- Configuring and enabling modules dynamically

### 3. [Client Development](/docs/development-client)
Explore building dynamic user interfaces, custom components, and declarative forms on the Reactory PWA Client.
- The Reactory SDK (`useReactory()` and `withReactory()`)
- Component FQNs and the dynamic component registry
- Declarative client routing and route guards
- The Reactory Form Engine (JSON Schema + UI Schema + custom widgets)
- Decoupled event communication via the client AMQ bus

### 4. [Styling & Theming](/docs/development-styling)
Master visual design, white-label theming, and responsive UI customization using Material-UI (MUI v5).
- Multi-tenant theme configurations (`IReactoryTheme`)
- Light and dark mode palettes with dynamic runtime toggling
- Component-level default props overrides (`MuiButton`, `MuiTextField`)
- Using the `sx` prop and `styled()` utilities in custom components

---

## 🛠️ Additional Resources

- **Interactive API Explorer**: Access the [GraphiQL Playground](/graphiql) to test queries and mutations live against the GraphQL schema.
- **Workflow Registry**: Manage and monitor automated execution graphs in the [Workflows Management](/workflows/registry) console.
- **Support & Help**: Need assistance? Submit a ticket via [Support Request](/support/request) or view existing issues in [My Support Tickets](/support/open).
