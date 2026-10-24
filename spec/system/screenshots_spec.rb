# frozen_string_literal: true

# README screenshots. Run by the "Screenshots" workflow, which commits the PNGs
# to docs/screenshots/. Skipped in regular CI.
RSpec.describe "Screenshots" do
  before { skip "set SCREENSHOTS=1 to take screenshots" unless ENV["SCREENSHOTS"] }

  let!(:component) { upload_theme_or_component }

  fab!(:author) { Fabricate(:user, username: "blog") }

  def save(name)
    path = Rails.root.join("tmp/capybara/screenshots/#{name}.png")
    FileUtils.mkdir_p(path.dirname)
    page.driver.with_playwright_page { |pw| pw.screenshot(path: path.to_s) }
  end

  it "renders the whole embedded article" do
    SiteSetting.embed_truncate = true
    topic = Fabricate(:topic, title: "Why we run our own infrastructure", user: author)
    post =
      Fabricate(
        :post,
        topic: topic,
        user: author,
        raw:
          "We moved every service we use off third-party platforms. Here is why, and what it cost…",
      )
    Fabricate(
      :topic_embed,
      post: post,
      topic: topic,
      embed_url: "https://blog.example.com/why-we-run-our-own-infrastructure",
      embed_content_cache: <<~HTML,
        <p>We moved every service we use off third-party platforms. Here is why, and what it cost.</p>
        <h2>Privacy is a property of the system</h2>
        <p>A promise in a privacy policy can change overnight. A server we control cannot start
        selling data behind our backs, and a member can read the code that handles their account.</p>
        <h2>What we run</h2>
        <ul>
          <li>The forum, on Discourse</li>
          <li>The blog, on Ghost</li>
          <li>Search, on SearXNG and Typesense</li>
          <li>Payments, on BTCPay Server</li>
        </ul>
        <h2>What it costs</h2>
        <p>Two small servers and a few hours a month. Less than the subscriptions it replaced.</p>
      HTML
    )

    resize_window(width: 1100, height: 900) do
      visit "/t/#{topic.slug}/#{topic.id}"
      expect(page).to have_css(".topic-post .cooked h2", text: "What it costs")
      save("full-article")
    end
  end

  it "folds a long article above the conversation" do
    SiteSetting.tagging_enabled = true
    component.update_setting(:collapse_tags, "blog")
    component.update_setting(:collapsed_height, 320)
    component.save!

    reader = Fabricate(:user, username: "reader")
    topic =
      Fabricate(
        :topic,
        title: "A field guide to self-custody",
        user: author,
        tags: [Fabricate(:tag, name: "blog")],
      )
    sections = {
      "Why custody matters" =>
        "Coins held by an exchange are a promise from that exchange. Coins held by your keys are yours.",
      "Choosing a wallet" =>
        "Pick one that is open source, has been around for years and lets you export your seed.",
      "Backups that survive" =>
        "Write the seed on steel, keep two copies in two places, and test a restore before you need it.",
      "Planning for inheritance" =>
        "Someone you trust should know where the backups are and how to use them, without holding them.",
    }
    raw =
      sections.map { |heading, text| "## #{heading}\n\n#{([text] * 3).join("\n\n")}" }.join("\n\n")
    Fabricate(:post, topic: topic, user: author, raw: raw)
    Fabricate(
      :post,
      topic: topic,
      user: reader,
      raw: "The backups section is the one I wish I had read a year ago.",
    )

    resize_window(width: 1100, height: 900) do
      visit "/t/#{topic.slug}/#{topic.id}"
      expect(page).to have_css(".collapsible-article.--collapsed")
      expect(page).to have_css("[data-post-number='2'] .cooked", text: "backups section")
      save("folded-article")
    end
  end
end
