# Client Development

The **Reactory PWA Client** is a responsive, extensible Progressive Web Application built on React, Material-UI (MUI v5), and Apollo Client. It provides a modular UI runtime where screens, dashboards, forms, and custom widgets can be rendered either declaratively from JSON schemas or implemented as rich React components.

This guide walks through the client architecture, component system, routing, state management, and the Form Engine.

---

## 1. Client Architecture Overview

The client application (`reactory-pwa-client`) operates around several key runtime concepts:

- **Reactory SDK (`reactory`)**: Available throughout the app via React context (`useReactory()` or `withReactory()`). The SDK provides access to GraphQL operations, client event bus (AMQ), authentication status, navigation, and the dynamic component registry.
- **Dynamic Component Registry**: Components are registered under Fully Qualified Names (FQNs), such as `core.StaticContent@1.0.0` or `core.SupportForm@1.0.0`, allowing forms and routes to resolve UI elements dynamically at runtime.
- **Declarative Form Engine**: Renders forms with two-way data binding, validations, and custom widgets directly from JSON Schema (draft-07) and UI Schema configurations.
- **Client Routing Engine**: Centralized route configuration with role-based access checks, layout selection, and dynamic path parameter binding.

---

## 2. Using the Reactory SDK & Context

Components gain access to platform capabilities via the `useReactory` hook:

```tsx
import React from 'react';
import { useReactory } from '@reactory/client-core/api';
import { Button, Box, Typography } from '@mui/material';

export const MyFeatureComponent: React.FC = () => {
  const reactory = useReactory();

  const handleNotify = () => {
    // Check roles
    if (reactory.hasRole(['ADMIN'])) {
      reactory.createNotification('Admin action triggered', { type: 'success' });
    }

    // Publish event across the client AMQ bus
    reactory.amq.publish('workflow', 'item.selected', { id: 'item-123' });
  };

  return (
    <Box sx={{ p: 2 }}>
      <Typography variant="h6">Welcome, {reactory.getUser()?.firstName}!</Typography>
      <Button variant="contained" color="primary" onClick={handleNotify}>
        Execute Action
      </Button>
    </Box>
  );
};

export default MyFeatureComponent;
```

---

## 3. Registering Custom Components & Widgets

Every reusable component or widget in Reactory is cataloged with an FQN.

### Component Registration Example
In your component file:

```tsx
import React from 'react';
import { compose } from 'redux';
import { withReactory } from '@reactory/client-core/api/ApiProvider';

interface UserBadgeProps {
  userId: string;
  reactory: Reactory.Client.ReactorySDK;
}

const UserBadge: React.FC<UserBadgeProps> = ({ userId, reactory }) => {
  return <div className="user-badge">User: {userId}</div>;
};

const ExportedComponent: any = compose(withReactory)(UserBadge);

ExportedComponent.meta = {
  nameSpace: 'custom',
  name: 'UserBadge',
  version: '1.0.0',
  component: ExportedComponent,
  title: 'User Badge',
  description: 'Displays user avatar and badge status',
  tags: ['user', 'badge', 'widget'],
};

export default ExportedComponent;
```

Once registered in the component catalog (`components/index.tsx` or dynamic plugin loader), this component can be instantiated via:
1. Direct JSX: `<ExportedComponent userId="123" />`
2. Dynamic lookup: `const { UserBadge } = reactory.getComponents(['custom.UserBadge@1.0.0']);`
3. Embedded in static markdown content via `<reactory fqn="custom.UserBadge@1.0.0" props='{"userId":"123"}' />`
4. Form UI Schemas: `"ui:widget": "custom.UserBadge@1.0.0"`

---

## 4. Configuring Application Routes

Routes are defined in client configurations under `src/data/clientConfigs/<app>/routes/index.ts`. 

Each route maps a path to a component FQN with access controls:

```typescript
const routes: Reactory.Routing.IReactoryRoute[] = [
  {
    key: "dashboard",
    title: "Executive Dashboard",
    path: "/dashboard",
    public: false,
    exact: true,
    roles: ["USER", "EXECUTIVE"],
    componentFqn: "crm.DashboardView@1.0.0",
  },
  {
    key: "docs-topic",
    title: "Documentation",
    path: "/docs/:slug",
    public: false,
    exact: false,
    roles: ["USER"],
    componentFqn: "core.StaticContent@1.0.0",
    componentProps: {
      slugSource: "route",
      slugSourceProps: {
        paramId: "slug",
        slugPrefix: "reactory-docs-",
      },
    },
  },
];

export default routes;
```

### Route Attributes:
- **`roles`**: Array of roles required to view the route. Unauthenticated users are redirected to login.
- **`public`**: When `true`, guests can access the route without logging in.
- **`componentProps`**: Static or dynamic props forwarded into the rendered component.
- **`slugSource`**: Used by `StaticContent` to pull slugs directly from route params.

---

## 5. The Reactory Form Engine

Reactory includes a schema-driven Form Engine based on JSON Schema (draft-07) and UI Schemas.

### How Forms Work:
1. **Schema (`schema`)**: Defines the data structure, types, field titles, validations, and mandatory fields.
2. **UI Schema (`uiSchema`)**: Defines widget types, field layouts, placeholders, and options.
3. **Data (`formData`)**: The JSON payload managed and submitted by the form.

### Form Definition Example:
```json
{
  "schema": {
    "type": "object",
    "required": ["projectName", "category"],
    "properties": {
      "projectName": {
        "type": "string",
        "title": "Project Name"
      },
      "category": {
        "type": "string",
        "title": "Category",
        "enum": ["Engineering", "Design", "Marketing"]
      },
      "description": {
        "type": "string",
        "title": "Overview"
      }
    }
  },
  "uiSchema": {
    "category": {
      "ui:widget": "select"
    },
    "description": {
      "ui:widget": "textarea",
      "ui:options": { "rows": 4 }
    }
  }
}
```

Forms support custom widgets, field templates, conditional schemas, server-side data mapping, and workflow submission triggers.

---

## 6. Client Event Bus (AMQ)

For loose coupling between separate UI components, Reactory includes a client-side AMQ event bus:

- **Publishing Events**:
  ```typescript
  reactory.amq.publish('crm', 'contact.selected', { contactId: 'abc-123' });
  ```

- **Subscribing to Events**:
  ```typescript
  useEffect(() => {
    const unsubscribe = reactory.amq.subscribe('crm', 'contact.selected', (data) => {
      console.log('Selected contact:', data.contactId);
    });
    return () => unsubscribe();
  }, [reactory]);
  ```

This allows side panels, forms, charts, and background workers to communicate seamlessly without drilling props.
