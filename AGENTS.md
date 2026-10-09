# Full embedded posts — agent guide

Rules for anyone changing this repo, people and AI agents alike. Org-wide
conventions (README, licenses, commits) are in the [contributing guide](https://github.com/somos-criptonautas/.github/blob/main/CONTRIBUTING.md).

## Checks

```bash
pnpm install && pnpm lint
discourse_theme rspec .
```

CI runs both. Screenshots in `docs/screenshots/` come from
`spec/system/screenshots_spec.rb` via Actions → Screenshots.

## Things that are easy to get wrong

- It calls core's own `post.expand()`, the same `/posts/:id/expand-embed` the
  "Show more" button uses. Keep it that way: no second request path, no scraping.
- Truncation happens at import. Settings changed later (`embed truncate`) only
  affect new imports; already imported topics stay truncated until reimported.
- On failure the button stays. Don't hide it or show an error.
