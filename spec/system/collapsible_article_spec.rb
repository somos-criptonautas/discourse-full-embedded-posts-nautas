# frozen_string_literal: true

RSpec.describe "Collapsible article" do
  let!(:component) { upload_theme_or_component }

  fab!(:tag) { Fabricate(:tag, name: "blog") }

  let(:long_raw) { (1..60).map { |i| "Paragraph #{i} of a long article." }.join("\n\n") }

  before do
    SiteSetting.tagging_enabled = true
    component.update_setting(:collapse_tags, "blog")
    component.update_setting(:collapsed_height, 300)
    component.save!
  end

  def article_topic(raw:, tags: [tag])
    topic = Fabricate(:topic, tags: tags)
    Fabricate(:post, topic: topic, raw: raw)
    Fabricate(:post, topic: topic, raw: "A reply that should never fold.")
    topic
  end

  it "folds a long tagged article and unfolds it on demand, leaving replies alone" do
    topic = article_topic(raw: long_raw)
    visit "/t/#{topic.slug}/#{topic.id}"

    expect(page).to have_css("[data-post-number='1'] .collapsible-article.--collapsed")
    expect(page).to have_no_css("[data-post-number='2'] .collapsible-article")

    find("[data-post-number='1'] .collapsible-article__toggle").click

    expect(page).to have_no_css(".collapsible-article.--collapsed")
    expect(page).to have_css(".collapsible-article__toggle[aria-expanded='true']")
  end

  it "does not fold a short tagged article" do
    topic = article_topic(raw: "Short enough to read in one go.")
    visit "/t/#{topic.slug}/#{topic.id}"

    expect(page).to have_css("[data-post-number='1'] .collapsible-article")
    expect(page).to have_no_css(".collapsible-article.--collapsed")
    expect(page).to have_no_css(".collapsible-article__toggle")
  end

  it "ignores topics without a configured tag" do
    topic = article_topic(raw: long_raw, tags: [])
    visit "/t/#{topic.slug}/#{topic.id}"

    expect(page).to have_css("[data-post-number='1'] .cooked")
    expect(page).to have_no_css(".collapsible-article")
  end
end
