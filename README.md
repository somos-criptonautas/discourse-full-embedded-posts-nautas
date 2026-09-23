# Full embedded posts

Discourse theme component for topics created by the [Embedding](https://meta.discourse.org/t/embedding-discourse-comments-via-javascript/31963)
feature from a Ghost blog:

- the whole article renders on load, instead of an excerpt plus a "Show more" button
- Ghost bookmark cards render as onebox-style cards
- Ghost callout cards render in the forum's callout palette, keeping Ghost's emoji

## Install

Admin → Customize → Themes → Components → Install → From a git repository, with this repo's URL.

## Required site setting

The card styling needs Ghost's classnames to survive the import. In `allowed embed classnames`,
**append** to the existing value (it defaults to `emoji` — don't replace it):

```
kg-card kg-bookmark-card kg-bookmark-container kg-bookmark-content kg-bookmark-title kg-bookmark-description kg-bookmark-metadata kg-bookmark-icon kg-bookmark-author kg-bookmark-publisher kg-bookmark-thumbnail kg-callout-card kg-callout-emoji kg-callout-text kg-callout-card-grey kg-callout-card-white kg-callout-card-blue kg-callout-card-green kg-callout-card-yellow kg-callout-card-red kg-callout-card-pink kg-callout-card-purple kg-callout-card-accent
```

Without it Discourse strips every `kg-*` class while scraping and the cards arrive as
unstyled piles of divs.

## Notes

Truncation and class stripping both happen at import: the excerpt becomes the post, the full
article is kept in `topic_embeds.embed_content_cache`. The component fetches it through the
same `/posts/:id/expand-embed` endpoint the button uses — server-cached, so your blog is not
re-crawled. If that request fails, the button is left in place.

Both the setting above and `embed truncate` only affect **future** imports. Already-imported
topics keep their stripped, truncated copy in the database until a rails-console
`TopicEmbed.import` reimport.

Cards are not oneboxed, by design: oneboxing runs server-side at cook time on `a.onebox`
links only, so converting a card to a onebox would mean rewriting the HTML before cook —
a plugin, not a theme.

## License

MIT
