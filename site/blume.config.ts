import { defineConfig } from "blume";

export default defineConfig({
  title: "dot",
  description: "Your Mac, as code. Set it up from plain text, keep it that way, and work on your projects.",
  // The docs live in the repo's docs/, served under /docs; the landing page
  // is pages/index.astro.
  basePath: "/docs",
  content: { root: "../docs" },
});
