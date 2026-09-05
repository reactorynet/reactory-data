# About Reactory Platform

**Reactory** is a modern, modular, low-code application development platform and enterprise engine designed to accelerate full-stack development, AI agent orchestration, and automated workflow management.

---

## Key Platform Capabilities

### 1. Rapid Application Development (RAD) & Low-Code Engine
- **JSON Schema Forms & UI Schemas**: Define dynamic forms, data models, and user interfaces declarative schema definitions.
- **Component & Plugin Ecosystem**: Dynamically load React components, widgets, and extension plugins at runtime.
- **Multi-Tenant Architecture**: Built-in support for multiple client applications, dynamic white-labeling, custom themes, and isolated data spaces.

### 2. Reactor AI & Agent Orchestration
- **Autonomous & Specialized Sub-Agents**: Orchestrate domain-focused AI agents (Security, Infrastructure, Data Analytics, Workflows) for complex, multi-step engineering tasks.
- **Self-Healing Development Loops**: Automated workflow triggers that execute test suites, analyze failures, apply fixes, and perform verified Git commits.
- **Neural Graph Integration**: Real-time representation of system concepts, code symbols, dependencies, and conversation history.

### 3. Reactory Workflow Engine
- **YAML & Code Workflow Execution**: Declarative workflow definitions supporting sequential and parallel step execution.
- **Event-Driven Bus (AMQ)**: Asynchronous client and server event bus for reactive UI updates and system-wide messaging.
- **Built-in Metrics & Error Diagnostic Tracking**: Comprehensive execution histories, step pointers, and error stack traces.

### 4. Data & Microservice Integration
- **GraphQL & REST API Support**: Unified GraphQL schema with role-based access control, custom directives, and automated resolver mapping.
- **Multi-Database Support**: Seamless connectivity across MongoDB, PostgreSQL, MySQL, MSSQL, and Redis.
- **Content Management Service**: Dynamic and static content ingestion with locale resolution and property sidecars.

---

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    Reactory PWA Client                      │
│      (Dynamic Forms, React Components, Theme Engine)        │
└──────────────────────────────┬──────────────────────────────┘
                               │ GraphQL / WebSocket / HTTP
┌──────────────────────────────▼──────────────────────────────┐
│                  Reactory Express Server                    │
│   ┌──────────────────────┬──────────────────────────────┐   │
│   │ reactory-core        │ reactory-reactor (AI)        │   │
│   │ Services, Workflows  │ Orchestration & Graph Engine │   │
│   └──────────────────────┴──────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────┘
                               │
 ┌─────────────────────────────┼─────────────────────────────┐
 │                             │                             │
 ▼                             ▼                             ▼
MongoDB                   PostgreSQL / SQL                 Disk / CDN
(Content & App Data)      (Relational Connections)         (Static Content)
```

---

## Getting Started

To explore or extend Reactory:
- Check out the **Reactory Documentation** and **Service Catalog**.
- Use the **Reactor AI Assistant** in chat sessions to explore codebases, manage workflows, or run automated verification tests.
