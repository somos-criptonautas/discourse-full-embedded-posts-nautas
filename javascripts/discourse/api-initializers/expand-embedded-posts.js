import { apiInitializer } from "discourse/lib/api";

// Posts already expanded — expand() replaces `cooked`, which re-runs decorators.
const expanded = new WeakSet();

export default apiInitializer((api) => {
  api.decorateCookedElement(
    (element, helper) => {
      const post = helper.model;
      if (!post?.expandablePost || expanded.has(post)) {
        return;
      }

      expanded.add(post);
      // expand() already pops an error toast, then rethrows.
      post.expand().catch(() => {});
    },
    { onlyStream: true }
  );
});
