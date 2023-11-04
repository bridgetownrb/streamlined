# frozen_string_literal: true

require "test_helper"

module TestHelpers
  def multiplied_by(input, multiplicand)
    input * multiplicand
  end
end

class TestComponent
  include Streamlined::Renderable
  include TestHelpers

  def initialize(name:, number:)
    @name, @number = name, number
  end

  def heading
    "I should be <\"escaped\">"
  end

  def markdown_content
    # simulate some external content
    %(<p class="markdown">I am Markdown.</p>).html_safe
  end

  def unsafe_content
    %(<script>alert("Boo!")</script>)
  end

  def template(&block)
    render do
      render html -> { <<~HTML
        <header>Site Header</header>
      HTML
      }

      render { markdown_content } if @number == 123
      render { ChildComponent.new }
      render { unsafe_content }
    end

    render html -> { <<~HTML
      <section>
        <h1>#{text -> { heading }}</h1>
        <h2>#{text -> { @name }}</h2>
        #{html -> { capture(self, &block) }}
        <footer>#{text -> { @number }.pipe { multiplied_by(10) }}</footer>
      </section>
    HTML
    }
  end
end

class ChildComponent
  include Streamlined::Renderable

  def template
    html -> { <<~HTML
      <p>I'm in a child component.</p>
    HTML
    }
  end
end

class TestStreamlined < Minitest::Test
  include Rails::Dom::Testing::Assertions

  attr_reader :document_root_element

  def document_root(root)
    @document_root_element = root.is_a?(Nokogiri::XML::Document) ? root : Nokogiri::HTML5(root)
  end

  def capture(*args)
    yield(*args)
  end

  def render(obj, &block)
    obj.render_in(self, &block)
  end

  def test_that_it_has_a_version_number
    refute_nil ::Streamlined::VERSION
  end

  def test_component_output
    document_root(
      render(TestComponent.new name: "Name", number: 123) do
        render ChildComponent.new
      end
    )

    output_html = document_root_element.to_html
    # puts output_html
    assert_includes output_html, %(&lt;script&gt;alert("Boo!")&lt;/script&gt;)
    refute_includes output_html, "<script>"

    header = css_select("header")[0]
    assert_equal "Site Header", header.inner_html

    markdown = css_select("p.markdown")
    assert_equal "I am Markdown.", markdown.inner_html

    section = css_select("section")[0]
    heading1 = section.css("h1")[0]

    assert_equal "I should be &lt;\"escaped\"&gt;", heading1.inner_html

    heading2 = section.css("h2")[0]
    assert_equal "Name", heading2.inner_html

    para = section.css("> p")[0]
    assert_equal "I'm in a child component.", para.inner_html

    footer = section.css("footer")[0]
    assert_equal "1230", footer.inner_html
  end
end
