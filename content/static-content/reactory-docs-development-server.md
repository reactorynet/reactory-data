# Module Development

Server Modules are the primary building blocks of the **Reactory Express Server**. Every major feature—whether it is authentication, a specialized business domain, an integration connector (such as Jira, Slack, Azure, or Google), or the Reactor AI runtime itself—is implemented as a self-contained, composable Reactory Module.

This guide explains how to architect, develop, test, and package backend server modules.

---

## 1. What is a Reactory Server Module?

A Reactory module bundles everything required to provide backend capabilities into a structured, isolated unit. At server startup, the server dynamically discovers and aggregates all enabled modules into a single unified GraphQL schema, dependency injection container, and workflow registry.

A module implements the `Reactory.Server.IReactoryModule` interface:

```typescript
export interface IReactoryModule {
  id: string;                      // Unique module identifier (e.g. 'acme-crm')
  nameSpace: string;               // Namespace for types and services (e.g. 'crm')
  version: string;                 // Semver string (e.g. '1.0.0')
  name: string;                    // Human-readable name
  description: string;             // Detailed module summary
  dependencies?: string[];         // Required module IDs
  priority?: number;               // Load priority order (lower runs earlier)
  graphDefinitions?: {             // GraphQL schema contributions
    Types: string[];               // Schema SDL definitions
    Resolvers: IReactoryResolverMap; // Query, Mutation & Type resolvers
    Directives?: any;              // Custom schema directives
  };
  services?: IReactoryServiceDefinition[]; // Injected domain services
  models?: IReactoryModelDefinition[];     // Mongoose / database models
  workflows?: IReactoryWorkflow[];         // Built-in workflow definitions
  forms?: IReactoryForm[];                 // Registered JSON Schema forms
  routes?: IReactoryRouteDefinition[];     // Custom Express HTTP endpoints
  middleware?: any[];                      // Express middleware functions
  cli?: IReactoryCliCommand[];             // CLI tools exposed to the console
  featureFlags?: IFeatureFlag[];           // Toggleable capability flags
}
```

---

## 2. Module Directory Structure

By convention, all modules reside under `src/modules/<module-name>/`. A typical module layout is organized as follows:

```text
src/modules/acme-billing/
├── index.ts                     # Main entry point exporting IReactoryModule
├── graph/
│   ├── types/                   # GraphQL SDL files (.graphql)
│   │   ├── Invoice.graphql
│   │   └── index.ts
│   ├── resolvers/               # Resolvers using @resolver decorators
│   │   ├── InvoiceResolver.ts
│   │   └── index.ts
│   └── directives/              # Custom GraphQL schema directives
├── services/                    # Domain services injected into IReactoryContext
│   ├── StripeBillingService.ts
│   └── index.ts
├── models/                      # Database schemas and models (Mongoose/SQL)
│   ├── InvoiceModel.ts
│   └── index.ts
├── workflows/                   # Pre-packaged YAML / code workflows
│   ├── ProcessInvoiceWorkflow.ts
│   └── index.ts
├── forms/                       # Declarative JSON Schema forms
│   ├── InvoiceCaptureForm/
│   │   ├── schema.json
│   │   └── uiSchema.json
│   └── index.ts
└── routes/                      # REST endpoints and webhooks
    ├── webhooks.ts
    └── index.ts
```

---

## 3. Developing GraphQL APIs

Reactory uses a declarative, decorator-based approach to construct GraphQL resolvers. This keeps business logic cleanly separated from schema mapping.

### 1. Define GraphQL Types
Create `.graphql` files in `graph/types/`:

```graphql
# src/modules/acme-billing/graph/types/Invoice.graphql

type AcmeInvoice {
  id: String!
  invoiceNumber: String!
  amount: Float!
  currency: String!
  status: String!
  dueDate: String
  createdAt: String!
  updatedAt: String!
}

input CreateInvoiceInput {
  customerId: String!
  amount: Float!
  currency: String!
  dueDate: String
}

extend type Query {
  getInvoiceById(id: String!): AcmeInvoice
  listInvoices(status: String, limit: Int): [AcmeInvoice]!
}

extend type Mutation {
  createInvoice(input: CreateInvoiceInput!): AcmeInvoice!
  markInvoicePaid(id: String!): AcmeInvoice!
}
```

### 2. Implement the Resolver Class
Use the Reactory decorators `@resolver`, `@query`, `@mutation`, `@property`, and `@roles`:

```typescript
// src/modules/acme-billing/graph/resolvers/InvoiceResolver.ts

import Reactory from '@reactorynet/reactory-core';
import { resolver, query, mutation, roles } from '@reactory/server-core/models/graphql/decorators/resolver';

@resolver
class InvoiceResolver {
  @roles(['USER', 'BILLING_ADMIN'], 'args.context')
  @query('getInvoiceById')
  async getInvoiceById(
    parent: unknown,
    args: { id: string },
    context: Reactory.Server.IReactoryContext
  ) {
    const billingService = context.getService<any>('acme.BillingService@1.0.0');
    return billingService.getInvoice(args.id);
  }

  @roles(['BILLING_ADMIN'], 'args.context')
  @mutation('createInvoice')
  async createInvoice(
    parent: unknown,
    args: { input: any },
    context: Reactory.Server.IReactoryContext
  ) {
    const billingService = context.getService<any>('acme.BillingService@1.0.0');
    return billingService.createInvoice(args.input, context.user);
  }
}

export default InvoiceResolver;
```

---

## 4. Authoring Injected Services

Services encapsulate domain logic, integration calls, external SDK clients, and data operations. Services are registered with the server and accessible anywhere via `context.getService<T>(serviceId)`.

### Example Service Implementation:

```typescript
// src/modules/acme-billing/services/BillingService.ts

import Reactory from '@reactorynet/reactory-core';

export class BillingService implements Reactory.Service.IReactoryService {
  name: string = 'BillingService';
  nameSpace: string = 'acme';
  version: string = '1.0.0';

  context: Reactory.Server.IReactoryContext;

  constructor(props: any, context: Reactory.Server.IReactoryContext) {
    this.context = context;
  }

  async getInvoice(id: string) {
    this.context.log(`Fetching invoice ${id}`, {}, 'debug');
    const { InvoiceModel } = this.context.models;
    return InvoiceModel.findById(id);
  }

  async createInvoice(input: any, user: Reactory.Models.IUser) {
    this.context.log(`User ${user.email} creating invoice`, input, 'info');
    const { InvoiceModel } = this.context.models;
    return InvoiceModel.create({
      ...input,
      createdBy: user._id,
      partner: this.context.partner?._id,
    });
  }
}

export default {
  service: (props: any, context: Reactory.Server.IReactoryContext) => new BillingService(props, context),
  name: 'BillingService',
  nameSpace: 'acme',
  version: '1.0.0',
};
```

---

## 5. Module Registration & Configuration

To make your module active in your development or production environment:

1. **Export the Module**:
   In `src/modules/acme-billing/index.ts`, assemble the `IReactoryModule` object and export it as the default export.

2. **Enable the Module**:
   Add the module definition to `src/modules/enabled-{setting_id}.json` (or `enabled-reactory.json`):

   ```json
   {
     "id": "acme-billing",
     "name": "AcmeBilling",
     "key": "acme-billing",
     "fqn": "acme.Billing@1.0.0",
     "moduleEntry": "acme-billing/index.ts",
     "license": "MIT",
     "description": "Acme Enterprise Billing and Invoicing Engine",
     "version": "1.0.0",
     "enabled": true
   }
   ```

3. **Restart the Server**:
   When the server boots, the dynamic loader compiles `modules/__index.ts`, initializes your schemas, and binds your services to the context.

---

## 6. Best Practices for Module Developers

- **Namespace Everything**: Always scope types, services, and forms with your unique `nameSpace` to prevent collisions across independent vendor modules.
- **Enforce RBAC via `@roles`**: Guard sensitive queries and mutations using the `@roles(['ROLE_A', 'ROLE_B'])` decorator.
- **Tenant Isolation**: Always scope database records to `context.partner?._id` when authoring multi-tenant features.
- **Use AMQ for Side Effects**: Instead of synchronizing tightly coupled operations, publish events on `context.emit()` or the AMQ channel so other modules can react asynchronously.
