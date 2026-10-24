import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { guidFor } from "@ember/object/internals";
import { modifier } from "ember-modifier";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";

// Folding away only a few lines reads as a broken cut-off, not a preview.
const MIN_OVERFLOW_RATIO = 1.25;

export default class CollapsibleArticle extends Component {
  // Claim this wrapper outlet only where it folds: core keeps a single wrapper
  // connector per outlet and flags any other component that also wraps it.
  static shouldRender({ post }) {
    if (
      post?.post_number !== 1 ||
      document.body.classList.contains("embed-mode")
    ) {
      return false;
    }

    const tags = settings.collapse_tags.split("|").filter(Boolean);
    // Current core sends tags as {id, name, slug}; older versions as names.
    return !!post.topic?.tags?.some((tag) => tags.includes(tag.name ?? tag));
  }

  @tracked expanded = false;
  @tracked tall = false;

  contentId = `collapsible-article-${guidFor(this)}`;

  // Measures the unclipped content, so images loading or the embed expanding
  // afterwards still decide whether there is anything to fold.
  measure = modifier((element) => {
    const observer = new ResizeObserver(([entry]) => {
      this.tall =
        entry.contentRect.height >
        settings.collapsed_height * MIN_OVERFLOW_RATIO;
    });
    observer.observe(element);
    return () => observer.disconnect();
  });

  get collapsed() {
    return this.tall && !this.expanded;
  }

  @action
  toggle() {
    this.expanded = !this.expanded;
  }

  // Tabbing onto a link in the clipped part would otherwise focus something
  // nobody can see.
  @action
  expandOnFocus() {
    if (this.collapsed) {
      this.expanded = true;
    }
  }

  <template>
    <div
      id={{this.contentId}}
      class={{concatClass
        "collapsible-article"
        (if this.collapsed "--collapsed")
      }}
      {{on "focusin" this.expandOnFocus}}
    >
      <div {{this.measure}}>{{yield}}</div>
    </div>

    {{#if this.tall}}
      <DButton
        class="btn-default collapsible-article__toggle"
        @action={{this.toggle}}
        @icon={{if this.expanded "chevron-up" "chevron-down"}}
        @label={{if
          this.expanded
          (themePrefix "collapsible_article.show_less")
          (themePrefix "collapsible_article.show_more")
        }}
        @ariaExpanded={{this.expanded}}
        @ariaControls={{this.contentId}}
      />
    {{/if}}
  </template>
}
