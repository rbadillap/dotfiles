import { defineComponents } from "blume";
import ThemeKey from "./components/ThemeKey.astro";

// Footer is a site-wide slot with no built-in: here it only carries the
// D-key theme switch, and renders nothing visible.
export default defineComponents({
  layout: { Footer: ThemeKey },
});
