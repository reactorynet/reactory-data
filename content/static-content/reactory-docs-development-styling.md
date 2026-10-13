# Styling & Theming

The Reactory platform provides an enterprise-grade styling and theming system built atop **Material-UI (MUI v5)**. It allows complete visual white-labeling, dynamic dark/light mode switching, brand asset injection, and granular component-level styling overrides across all applications.

This guide explains how themes are defined, how component overrides work, and how to style custom components within the Reactory ecosystem.

---

## 1. Theming Architecture Overview

Reactory decouples visual styling from core logic through multi-tenant client configurations (`src/data/clientConfigs/<app>/themes/`):

- **Declarative Theme Configurations (`IReactoryTheme`)**: Themes define light and dark modes, brand assets (logos, avatars, splash images), layout structures, and default component props.
- **Dynamic Palette Switching**: Users can seamlessly toggle between light and dark modes at runtime. The theme state is managed centrally and notifies registered components via SDK events.
- **Component Default Props Overrides**: Platform-wide defaults ensure consistent design tokens across complex forms, buttons, inputs, and modals without requiring redundant props on every JSX element.

---

## 2. Defining a Reactory Theme

A complete theme implements `Reactory.UX.IReactoryTheme`:

```typescript
// src/data/clientConfigs/<app>/themes/customTheme/index.ts

import Reactory from '@reactorynet/reactory-core';
import { ThemeOptions } from '@mui/material/styles';
import { safeCDNUrl } from '@reactory/server-core/utils/url/safeUrl';

// Global component overrides
const COMPONENT_OVERRIDES: ThemeOptions['components'] = {
  MuiButton: {
    defaultProps: {
      variant: 'contained',
      disableElevation: false,
    },
  },
  MuiTextField: {
    defaultProps: {
      variant: 'outlined',
      size: 'small',
    },
  },
  MuiSelect: {
    defaultProps: {
      variant: 'outlined',
      size: 'small',
    },
  },
};

// Dark Mode Palette
const DARK_PALETTE: Reactory.UX.ITheme & ThemeOptions = {
  type: 'material',
  components: COMPONENT_OVERRIDES,
  palette: {
    mode: 'dark',
    primary: {
      light: '#4f5b66',
      main: '#f95e20',
      dark: '#b93e10',
      contrastText: '#ffffff',
    },
    secondary: {
      light: '#a5392a',
      main: '#700000',
      dark: '#430000',
      contrastText: '#ffffff',
    },
    background: {
      paper: '#2c2c2c',
      default: '#1e1e1e',
    },
    text: {
      primary: '#ffffff',
      secondary: '#b0bec5',
    },
  },
};

// Light Mode Palette
const LIGHT_PALETTE: Reactory.UX.ITheme & ThemeOptions = {
  type: 'material',
  components: COMPONENT_OVERRIDES,
  palette: {
    mode: 'light',
    primary: {
      light: '#ff8d00',
      main: '#e65100',
      dark: '#ac1900',
      contrastText: '#ffffff',
    },
    secondary: {
      light: '#9968ED',
      main: '#651fff',
      dark: '#0100ca',
      contrastText: '#ffffff',
    },
    background: {
      paper: '#ffffff',
      default: '#f4f6f8',
    },
  },
};

const CustomTheme: Reactory.UX.IReactoryTheme = {
  type: 'material',
  name: 'custom-theme',
  description: 'Corporate Custom Theme',
  defaultThemeMode: 'dark',
  modes: [
    {
      mode: 'dark',
      options: DARK_PALETTE,
      name: 'Dark Mode',
      description: 'Default Dark Mode',
      icon: 'night',
    },
    {
      mode: 'light',
      options: LIGHT_PALETTE,
      name: 'Light Mode',
      description: 'Default Light Mode',
      icon: 'day',
    },
  ],
  assets: [
    { id: 'logo', name: 'logo', url: safeCDNUrl('themes/custom/logo.png'), assetType: 'image' },
    { id: 'favicon', name: 'favicon', url: safeCDNUrl('themes/custom/favicon.png'), assetType: 'image' },
  ],
  content: {
    appTitle: 'Enterprise Suite',
    login: {
      message: 'Secure Enterprise Access',
    },
  },
};

export default CustomTheme;
```

---

## 3. Component Styling Best Practices

When styling custom React components and widgets in the Reactory ecosystem, follow these recommended approaches:

### 1. The `sx` Prop (Recommended for Layout & Views)
MUI's `sx` prop is performant, supports responsive breakpoints, and accesses theme tokens directly:

```tsx
import React from 'react';
import { Box, Typography } from '@mui/material';

export const MetricCard: React.FC<{ label: string; value: string | number }> = ({ label, value }) => (
  <Box
    sx={{
      p: 2,
      borderRadius: 2,
      backgroundColor: 'background.paper',
      boxShadow: 1,
      border: '1px solid',
      borderColor: 'divider',
      transition: 'box-shadow 0.2s ease-in-out',
      '&:hover': {
        boxShadow: 4,
      },
    }}
  >
    <Typography variant="caption" color="text.secondary">
      {label}
    </Typography>
    <Typography variant="h5" color="primary.main" sx={{ fontWeight: 600, mt: 0.5 }}>
      {value}
    </Typography>
  </Box>
);
```

### 2. The `styled()` Utility (For Reusable Primitives)
Create styled primitives when sharing complex CSS rules across multiple components:

```tsx
import { styled } from '@mui/material/styles';
import { Paper } from '@mui/material';

export const StyledDashboardPanel = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(3),
  borderRadius: theme.shape.borderRadius * 1.5,
  backgroundColor: theme.palette.mode === 'dark' ? '#252525' : '#ffffff',
  border: `1px solid ${theme.palette.divider}`,
}));
```

---

## 4. Theme Hooks & Dynamic Mode Switching

In custom components, inspect the current theme or listen for mode changes:

```tsx
import React from 'react';
import { useTheme } from '@mui/material/styles';
import { IconButton, Tooltip } from '@mui/material';
import DarkModeIcon from '@mui/icons-material/DarkMode';
import LightModeIcon from '@mui/icons-material/LightMode';
import { useReactory } from '@reactory/client-core/api';

export const ThemeModeToggle: React.FC = () => {
  const theme = useTheme();
  const reactory = useReactory();
  const isDark = theme.palette.mode === 'dark';

  const toggleMode = () => {
    const newMode = isDark ? 'light' : 'dark';
    reactory.setThemeMode(newMode);
  };

  return (
    <Tooltip title={`Switch to ${isDark ? 'light' : 'dark'} mode`}>
      <IconButton onClick={toggleMode} color="inherit">
        {isDark ? <LightModeIcon /> : <DarkModeIcon />}
      </IconButton>
    </Tooltip>
  );
};
```

---

## 5. Styling Forms and Static Content

- **JSON Schema Forms**: Form fields automatically inherit the active theme’s component overrides (`MuiTextField`, `MuiSelect`, `MuiButton`). You can pass custom `uiSchema` options (`"ui:options": { "className": "custom-class" }`) for specialized field styling.
- **Static Content**: The `core.StaticContent` component wraps content in the resolved container (`Box` or `Paper`) and supports custom styling via the `style` or `containerProps.sx` properties.
