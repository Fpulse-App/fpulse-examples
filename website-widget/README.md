# Feedback widget

Paste one script tag and a feedback button appears on every page. Colors, texts, rating type
(thumbs, emoji, stars or NPS), theme and position are set in the dashboard, so you never need to change the code again.

```html
<script src="https://fpulse.app/w/YOUR_WIDGET_ID.js" async></script>
```

Get `YOUR_WIDGET_ID` (it starts with `fp_`) on the **Widget** page of the [dashboard](https://fpulse.app/dashboard/widget?utm_source=github&utm_medium=examples).

| Folder | Where the snippet goes |
|--------|------------------------|
| [`html/`](html) | Any website: just before `</body>` |
| [`react/`](react) | Vite or Create React App: `index.html` |
| [`nextjs/`](nextjs) | `app/layout.tsx` with `next/script` |
| [`vue/`](vue) | Vue (`index.html`) or Nuxt (`nuxt.config.ts`) |
| [`wordpress-plugin/`](wordpress-plugin) | WordPress plugin: Settings > F-Pulse Feedback |

Website builders (Shopify, Webflow, Wix, Squarespace, Google Tag Manager) have step-by-step guides at
[fpulse.app/feedback-widget/shopify](https://fpulse.app/feedback-widget/shopify?utm_source=github&utm_medium=examples) and the pages linked from there.

## Tips

- Add `?env=dev` to the script URL on a test or staging site to keep its feedback separate.
- Use **Allowed domains** on the Widget page so only your sites can send feedback with your widget ID.
- With `async` the script loads without blocking your page, and it does not set cookies.
