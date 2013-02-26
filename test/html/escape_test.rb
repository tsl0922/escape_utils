require File.expand_path("../../helper", __FILE__)

class HtmlEscapeTest < MiniTest::Unit::TestCase
  def test_escape_basic_html_with_secure
    assert_equal "&lt;some_tag&#47;&gt;", EscapeUtils.escape_html("<some_tag/>")

    secure_before = EscapeUtils.html_secure
    EscapeUtils.html_secure = true
    assert_equal "&lt;some_tag&#47;&gt;", EscapeUtils.escape_html("<some_tag/>")
    EscapeUtils.html_secure = secure_before
  end

  def test_escape_basic_html_without_secure
    assert_equal "&lt;some_tag/&gt;", EscapeUtils.escape_html("<some_tag/>", false)

    secure_before = EscapeUtils.html_secure
    EscapeUtils.html_secure = false
    assert_equal "&lt;some_tag/&gt;", EscapeUtils.escape_html("<some_tag/>")
    EscapeUtils.html_secure = secure_before
  end

  def test_escape_double_quotes
    assert_equal "&lt;some_tag some_attr=&quot;some value&quot;&#47;&gt;", EscapeUtils.escape_html("<some_tag some_attr=\"some value\"/>")
  end

  def test_escape_single_quotes
    assert_equal "&lt;some_tag some_attr=&#39;some value&#39;&#47;&gt;", EscapeUtils.escape_html("<some_tag some_attr='some value'/>")
  end

  def test_escape_ampersand
    assert_equal "&lt;b&gt;Bourbon &amp; Branch&lt;&#47;b&gt;", EscapeUtils.escape_html("<b>Bourbon & Branch</b>")
  end

  def test_returns_original_if_not_escaped
    str = 'foobar'
    assert_equal str.object_id, EscapeUtils.escape_html(str).object_id
  end

  if RUBY_VERSION =~ /^1.9/
    def test_utf8_or_ascii_input_only
      str = "<b>Bourbon & Branch</b>"

      str.force_encoding 'ISO-8859-1'
      assert_raises Encoding::CompatibilityError do
        EscapeUtils.escape_html(str)
      end

      str.force_encoding 'UTF-8'
      begin
        EscapeUtils.escape_html(str)
      rescue Encoding::CompatibilityError => e
        assert_nil e, "#{e.class.name} raised, expected not to"
      end
    end

    def test_return_value_is_tagged_as_utf8
      str = "<b>Bourbon & Branch</b>".encode('utf-8')
      assert_equal Encoding.find('UTF-8'), EscapeUtils.escape_html(str).encoding
    end
  end
end