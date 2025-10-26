# Beaker AI Design System

A themeable design system built with CSS variables, Tailwind CSS, and Rails ViewComponents, inspired by shadcn/ui's token architecture.

## Overview

This design system supports:
- Light and dark themes
- Runtime theme switching
- HSL color space for better alpha channel manipulation
- Semantic color tokens
- Mobile-first responsive components
- WCAG 2.1 AA accessibility standards

## Table of Contents

1. [Design Tokens](#design-tokens)
2. [Components](#components)
3. [Theme Customization](#theme-customization)
4. [Usage Examples](#usage-examples)
5. [Accessibility](#accessibility)

---

## Design Tokens

### Color Tokens (HSL Values)

All colors use HSL format for better manipulation with alpha channels:

```css
/* Light Theme */
--background: 0 0% 100%;           /* White */
--foreground: 222.2 84% 4.9%;      /* Near black */
--primary: 221.2 83.2% 53.3%;      /* Blue */
--destructive: 0 84.2% 60.2%;      /* Red */
--muted: 210 40% 96.1%;            /* Light gray */
```

**Usage in Tailwind:**
```html
<div class="bg-primary text-primary-foreground">
  Primary colored element
</div>

<!-- With opacity -->
<div class="bg-primary/50">
  50% opacity primary
</div>
```

### Complete Color Palette

#### Semantic Colors
- `background` - Page background
- `foreground` - Main text color
- `primary` - Primary brand color (CTAs, links)
- `secondary` - Secondary actions
- `destructive` - Errors, dangerous actions
- `muted` - Subtle backgrounds, disabled states
- `accent` - Hover states, highlights

#### UI Elements
- `card` - Card backgrounds
- `popover` - Popover/dropdown backgrounds
- `border` - Border colors
- `input` - Input field borders
- `ring` - Focus ring color

### Typography

```css
--font-sans: ui-sans-serif, system-ui, -apple-system, ...;
--font-mono: ui-monospace, SFMono-Regular, ...;
```

**Tailwind classes:** Use default Tailwind typography scale (`text-sm`, `text-base`, `text-lg`, etc.)

### Border Radius

```css
--radius-sm: 0.25rem;  /* 4px */
--radius-md: 0.5rem;   /* 8px */
--radius-lg: 0.75rem;  /* 12px */
--radius-xl: 1rem;     /* 16px */
```

**Tailwind classes:** `rounded-radius`, `rounded-radius-sm`, `rounded-radius-lg`, etc.

### Shadows

```css
--shadow-sm: subtle elevation
--shadow-md: medium elevation (cards)
--shadow-lg: high elevation (dialogs)
--shadow-xl: highest elevation (modals)
```

**Tailwind classes:** `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`

---

## Components

### Button Component

**Variants:** `default`, `destructive`, `outline`, `secondary`, `ghost`, `link`  
**Sizes:** `sm`, `default`, `lg`, `icon`

```erb
<%# Default primary button %>
<%= render Primitives::ButtonComponent.new { "Click me" } %>

<%# Destructive action %>
<%= render Primitives::ButtonComponent.new(variant: :destructive) { "Delete" } %>

<%# Loading state %>
<%= render Primitives::ButtonComponent.new(loading: true) %>

<%# Large size %>
<%= render Primitives::ButtonComponent.new(size: :lg) { "Get Started" } %>

<%# Custom HTML attributes %>
<%= render Primitives::ButtonComponent.new(
  type: "submit",
  class: "w-full",
  data: { action: "click->form#submit" }
) { "Submit" } %>
```

**Props:**
- `variant:` Symbol - Button style variant (default: `:default`)
- `size:` Symbol - Button size (default: `:default`)
- `loading:` Boolean - Show loading spinner (default: `false`)
- `type:` String - Button type attribute (default: `"button"`)
- `disabled:` Boolean - Disable button (default: `false`)
- `**html_options` - Any additional HTML attributes

**Accessibility:**
- Minimum 44px height for touch targets
- Visible focus ring (2px offset)
- Disabled state prevents interaction
- Loading state disables button automatically

---

### Input Component

**Types:** `text`, `email`, `tel`, `password`, etc.

```erb
<%# Basic input with label %>
<%= render Primitives::InputComponent.new(
  name: "email",
  type: "email",
  label: "Email Address",
  placeholder: "name@example.com"
) %>

<%# Required field with helper text %>
<%= render Primitives::InputComponent.new(
  name: "username",
  label: "Username",
  helper_text: "This will be your public display name",
  required: true
) %>

<%# Input with error %>
<%= render Primitives::InputComponent.new(
  name: "password",
  type: "password",
  label: "Password",
  value: @user.password,
  error: @user.errors[:password].first
) %>
```

**Props:**
- `name:` String - Input name attribute (required)
- `type:` String - Input type (default: `"text"`)
- `value:` String - Input value
- `label:` String - Label text
- `error:` String - Error message (overrides helper text)
- `helper_text:` String - Helper text below input
- `placeholder:` String - Placeholder text
- `required:` Boolean - Show required indicator (default: `false`)
- `**html_options` - Any additional HTML attributes

**Accessibility:**
- Labels associated with inputs via `for`/`id`
- Error messages have `role="alert"`
- `aria-invalid` set when error present
- `aria-describedby` links to helper/error text

---

### Card Component

```erb
<%# Simple card %>
<%= render Primitives::CardComponent.new do %>
  <p>Card content goes here</p>
<% end %>

<%# Card with title and description %>
<%= render Primitives::CardComponent.new do |card| %>
  <% card.with_title { "Card Title" } %>
  <% card.with_description { "Card description text" } %>
  
  <p>Main card content</p>
<% end %>

<%# Card with footer %>
<%= render Primitives::CardComponent.new do |card| %>
  <% card.with_title { "Subscription" } %>
  
  <p class="text-2xl font-bold">$199/mo</p>
  
  <% card.with_footer do %>
    <%= render Primitives::ButtonComponent.new { "Upgrade" } %>
  <% end %>
<% end %>

<%# Custom header (replaces title/description) %>
<%= render Primitives::CardComponent.new do |card| %>
  <% card.with_header do %>
    <div class="flex items-center justify-between">
      <h3>Custom Header</h3>
      <span class="text-sm">Badge</span>
    </div>
  <% end %>
  
  <p>Content</p>
<% end %>
```

**Slots:**
- `header` - Custom header (replaces title/description)
- `title` - Card title (h3)
- `description` - Card description (muted text)
- `footer` - Card footer section

**Props:**
- `**html_options` - Any HTML attributes (e.g., `class`, `id`, `data`)

---

### Toast Component

**Variants:** `default`, `success`, `error`, `warning`

```erb
<%# Success toast %>
<%= render Primitives::ToastComponent.new(
  variant: :success,
  title: "Success!",
  message: "Your changes have been saved"
) %>

<%# Error toast %>
<%= render Primitives::ToastComponent.new(
  variant: :error,
  title: "Error",
  message: "Something went wrong"
) %>

<%# Non-dismissible toast %>
<%= render Primitives::ToastComponent.new(
  title: "Processing...",
  dismissible: false,
  auto_dismiss: false
) %>

<%# Custom content %>
<%= render Primitives::ToastComponent.new(title: "Notification") do %>
  <div class="flex gap-2">
    <button>Action 1</button>
    <button>Action 2</button>
  </div>
<% end %>
```

**Props:**
- `variant:` Symbol - Toast style (default: `:default`)
- `title:` String - Toast title
- `message:` String - Toast message
- `dismissible:` Boolean - Show close button (default: `true`)
- `auto_dismiss:` Boolean - Auto dismiss after 5s (default: `true`)
- `**html_options` - Any additional HTML attributes

**Behavior:**
- Auto-dismisses after 5 seconds (unless `auto_dismiss: false`)
- Slide-in animation from top
- Dismiss button in top-right corner
- Stimulus controller handles animations

---

## Theme Customization

### Switching Themes at Runtime

The theme controller automatically:
1. Reads user preference from localStorage
2. Falls back to system preference (`prefers-color-scheme`)
3. Applies theme on page load (no flash)
4. Persists theme choice

**Manual theme toggle:**
```erb
<button data-action="click->theme#toggle">
  Toggle Theme
</button>
```

**Listen to theme changes:**
```javascript
document.addEventListener('theme:changed', (event) => {
  console.log('Theme changed to:', event.detail.theme);
});
```

### Creating Custom Themes

#### Option 1: Override CSS Variables

```css
/* Add to tokens.css */
.theme-hvac {
  --primary: 199 89% 48%;  /* HVAC blue */
  --secondary: 142 71% 45%; /* Green accent */
}

.dark.theme-hvac {
  --primary: 199 89% 58%;
}
```

Apply via class:
```html
<body data-controller="theme" class="theme-hvac">
```

#### Option 2: Industry-Specific Presets

```ruby
# app/helpers/theme_helper.rb
module ThemeHelper
  INDUSTRY_THEMES = {
    hvac: "theme-hvac",
    gym: "theme-gym",
    dental: "theme-dental"
  }
  
  def industry_theme_class(industry)
    INDUSTRY_THEMES[industry.to_sym]
  end
end
```

```erb
<body data-controller="theme" class="<%= industry_theme_class(@business.industry) %>">
```

### Color Palette Reference

**Light Theme:**
- Background: `hsl(0 0% 100%)` - Pure white
- Foreground: `hsl(222.2 84% 4.9%)` - Near black
- Primary: `hsl(221.2 83.2% 53.3%)` - Blue
- Primary Foreground: `hsl(210 40% 98%)` - Light text
- Destructive: `hsl(0 84.2% 60.2%)` - Red
- Muted: `hsl(210 40% 96.1%)` - Light gray
- Border: `hsl(214.3 31.8% 91.4%)` - Gray border

**Dark Theme:**
- Background: `hsl(222.2 84% 4.9%)` - Near black
- Foreground: `hsl(210 40% 98%)` - Light text
- Primary: `hsl(217.2 91.2% 59.8%)` - Lighter blue
- Destructive: `hsl(0 62.8% 30.6%)` - Darker red
- Muted: `hsl(217.2 32.6% 17.5%)` - Dark gray
- Border: `hsl(217.2 32.6% 17.5%)` - Dark border

---

## Usage Examples

### Login Form

```erb
<div class="min-h-screen flex items-center justify-center bg-background p-4">
  <%= render Primitives::CardComponent.new(class: "w-full max-w-md") do |card| %>
    <% card.with_title { "Welcome back" } %>
    <% card.with_description { "Enter your credentials to sign in" } %>
    
    <%= form_with url: session_path, class: "space-y-4 mt-6" do |f| %>
      <%= render Primitives::InputComponent.new(
        name: "email",
        type: "email",
        label: "Email",
        placeholder: "name@example.com",
        required: true
      ) %>
      
      <%= render Primitives::InputComponent.new(
        name: "password",
        type: "password",
        label: "Password",
        required: true
      ) %>
      
      <%= render Primitives::ButtonComponent.new(
        type: "submit",
        size: :lg,
        class: "w-full"
      ) { "Sign In" } %>
    <% end %>
  <% end %>
</div>
```

### Dashboard Card with Stats

```erb
<%= render Primitives::CardComponent.new do |card| %>
  <% card.with_title { "Monthly Stats" } %>
  <% card.with_description { "Your performance this month" } %>
  
  <div class="grid grid-cols-3 gap-4 mt-4">
    <div>
      <p class="text-2xl font-bold text-foreground">247</p>
      <p class="text-sm text-muted-foreground">Calls</p>
    </div>
    <div>
      <p class="text-2xl font-bold text-foreground">18</p>
      <p class="text-sm text-muted-foreground">Leads</p>
    </div>
    <div>
      <p class="text-2xl font-bold text-foreground">42%</p>
      <p class="text-sm text-muted-foreground">Conv. Rate</p>
    </div>
  </div>
<% end %>
```

### Toast Notifications via Turbo Streams

```ruby
# app/controllers/calls_controller.rb
def create
  @call = current_user.calls.create(call_params)
  
  if @call.persisted?
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("toasts", 
          Primitives::ToastComponent.new(
            variant: :success,
            title: "Call started",
            message: "You'll receive the call shortly"
          )
        )
      end
    end
  end
end
```

```erb
<%# app/views/layouts/application.html.erb %>
<div id="toasts" class="fixed top-4 right-4 z-50 flex flex-col gap-2"></div>
```

---

## Accessibility

### Keyboard Navigation

All interactive components support keyboard navigation:
- **Tab** - Move focus between elements
- **Shift + Tab** - Move focus backward
- **Enter/Space** - Activate buttons
- **Escape** - Close modals/toasts (future)

### Focus Indicators

All focusable elements have visible 2px focus rings:
```css
focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2
```

### Screen Readers

- Semantic HTML (`button`, `input`, `label`)
- ARIA labels for icon-only buttons
- `role="alert"` for error messages
- `aria-invalid` for invalid inputs
- `aria-describedby` for helper text

### Color Contrast

All color combinations meet WCAG 2.1 AA standards:
- Normal text: 4.5:1 contrast ratio
- Large text: 3:1 contrast ratio
- UI components: 3:1 contrast ratio

Test contrast: [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

### Touch Targets

All interactive elements meet mobile accessibility:
- Minimum 44px height/width
- Adequate spacing between touch targets
- No overlapping interactive elements

---

## ViewComponent Previews

Access component previews in development:

```
http://localhost:3000/rails/view_components
```

Available previews:
- Button - All Variants
- Button - Loading State
- Input - All States
- Card - With Slots
- Toast - All Variants

Each preview includes a theme toggle to test both light and dark themes.

---

## Future Enhancements

Planned for Phase 1-6 based on actual needs:

- **Phase 2:** AudioPlayer, Transcript, Badge, StatTile
- **Phase 4:** Table, EmptyState, Dialog/Modal, Dropdown
- **Phase 6:** Chart wrapper (Chartkick integration)

Components will be added on-demand as tickets require them, not preemptively.

---

## Questions?

See also:
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [ViewComponent Guide](https://viewcomponent.org/)
- [shadcn/ui (inspiration)](https://ui.shadcn.com/)

