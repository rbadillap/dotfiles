import { defineConfig } from "blume";

// Code in the brand's zinc ladder (DESIGN.md v4.0: no color outside it):
// body ink for code, muted for comments, on the ratified --muted surface.
const zinc = (mode: "light" | "dark") => {
  const [ground, body, muted] =
    mode === "light" ? ["#f4f4f2", "#52525b", "#a1a1aa"] : ["#18181b", "#a1a1aa", "#71717a"];
  return {
    name: `rbadillap-zinc-${mode}`,
    type: mode,
    colors: { "editor.background": ground, "editor.foreground": body },
    tokenColors: [
      { settings: { foreground: body } },
      { scope: ["comment", "punctuation.definition.comment"], settings: { foreground: muted } },
    ],
  };
};

export default defineConfig({
  title: "dot",
  description: "Your Mac, as code. Set it up from plain text, keep it that way, and work on your projects.",
  // The docs live in the repo's docs/, served under /docs; the landing page
  // is pages/index.astro.
  basePath: "/docs",
  content: { root: "../docs" },
  // The rbadillap brand (DESIGN.md v4.0); tokens in theme.css.
  logo: { image: "/mark.svg", text: "dot" },
  markdown: {
    code: { icons: false, theme: { light: zinc("light"), dark: zinc("dark") } },
  },
  theme: {
    mode: "system",
    radius: "none",
    fonts: {
      display: { name: "Schibsted Grotesk", weights: [400, 500] },
      body: { name: "Schibsted Grotesk", weights: [400, 500] },
      mono: "jetbrains-mono",
    },
  },
});
