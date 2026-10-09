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
end
