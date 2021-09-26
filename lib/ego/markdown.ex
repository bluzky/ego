defmodule Ego.Markdown do
  @moduledoc false

  @doc """
  Parses given `doc_content` according to `doc_format`.
  """
  def parse!(markdown, opts \\ []) do
    parse_markdown(markdown, opts)
  end

  # https://www.w3.org/TR/2011/WD-html-markup-20110113/syntax.html#void-element
  @void_elements ~W(area base br col command embed hr img input keygen link 
    meta param source track wbr)a

  @doc """
  Transform AST into string.
  """
  def to_html(ast, fun \\ fn _ast, string -> string end)

  def to_html(binary, _fun) when is_binary(binary) do
    binary
  end

  def to_html(list, fun) when is_list(list) do
    result = Enum.map_join(list, "", &to_html(&1, fun))
    fun.(list, result)
  end

  def to_html({tag, attrs, _inner, _meta} = ast, fun) when tag in @void_elements do
    result = "<#{tag}#{ast_attributes_to_string(attrs)}/>"
    fun.(ast, result)
  end

  def to_html({tag, attrs, inner, %{verbatim: true}} = ast, fun) do
    inner = Enum.join(inner, "")
    result = "<#{tag}#{ast_attributes_to_string(attrs)}>" <> inner <> "</#{tag}>"
    fun.(ast, result)
  end

  def to_html({tag, attrs, inner, _meta} = ast, fun) do
    attrs = put_anchor_id(ast)
    result = "<#{tag}#{ast_attributes_to_string(attrs)}>" <> to_html(inner, fun) <> "</#{tag}>"
    fun.(ast, result)
  end

  defp put_anchor_id({tag, attrs, inner, _meta} = ast) do
    if tag in ~w(h1 h2 h3 h4 h5 h6) do
      id =
        inner
        |> to_text()
        |> Slug.slugify()
        |> String.slice(0, 50)

      [{:id, id} | attrs]
    else
      attrs
    end
  end

  defp ast_attributes_to_string(attrs) do
    Enum.map(attrs, fn {key, val} -> " #{key}=\"#{val}\"" end)
  end

  @doc """
  Transform AST into string.
  """
  def to_text(ast, fun \\ fn _ast, string -> string end)

  def to_text(binary, _fun) when is_binary(binary) do
    binary
  end

  def to_text(list, fun) when is_list(list) do
    result = Enum.map_join(list, "", &to_text(&1, fun))
    fun.(list, result)
  end

  def to_text({tag, attrs, _inner, _meta} = ast, fun) when tag in @void_elements do
    fun.(ast, "")
  end

  def to_text({tag, attrs, inner, %{verbatim: true}} = ast, fun) do
    inner = Enum.join(inner, "")
    result = inner <> "\n"
    fun.(ast, result)
  end

  def to_text({tag, attrs, inner, _meta} = ast, fun) do
    result = to_text(inner, fun) <> ((need_new_line?(tag) && "\n") || "")
    fun.(ast, result)
  end

  defp need_new_line?(tag) do
    tag in ~w(h1 h2 h3 h4 h5 h6 div hr p br)
  end

  @doc """
  """

  # def extract_toc(ast, fun \\ fn _ast, acc -> acc end)

  # def extract_toc(list, func) when is_list(list) do
  # end

  # def extract_toc({tag, attrs, inner, _meta} = ast, fun, acc \\ []) do
  #   if is_header(tag) do
  #     %{
  #       label: "",
  #       slug: "",
  #       children: ""
  #     }
  #   end

  # end

  # defp is_header(tag) do
  #   tag in ~w(h1 h2 h3 h4 h5 h6)
  # end

  ## parse markdown

  defp parse_markdown(text, opts) do
    options = [
      # gfm: true,
      # line: 1,
      # file: "nofile",
      # breaks: false,
      # smartypants: false,
      # pure_links: true
    ]

    options = Keyword.merge(options, opts)

    case EarmarkParser.as_ast(text, options) do
      {:ok, ast, messages} ->
        print_messages(messages, options)
        ast

      {:error, ast, messages} ->
        print_messages(messages, options)
        ast
    end
  end

  defp print_messages(messages, options) do
    for {severity, line, message} <- messages do
      file = options[:file]
      IO.warn("#{inspect(__MODULE__)} (#{severity}) #{file}:#{line} #{message}", [])
    end
  end

  @doc """
  Highlights a DocAST converted to string.
  """
  def highlight(html, language, opts \\ []) do
    highlight_info = language.highlight_info()

    Regex.replace(
      ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/,
      html,
      &highlight_code_block(&1, &2, &3, highlight_info, opts)
    )
  end

  defp highlight_code_block(full_block, lang, code, highlight_info, outer_opts) do
    case pick_language_and_lexer(lang, highlight_info, code) do
      {_language, nil, _opts} -> full_block
      {language, lexer, opts} -> render_code(language, lexer, opts, code, outer_opts)
    end
  end

  defp pick_language_and_lexer("", _highlight_info, "$ " <> _) do
    {"shell", ExDoc.ShellLexer, []}
  end

  defp pick_language_and_lexer("", highlight_info, _code) do
    {highlight_info.language_name, highlight_info.lexer, highlight_info.opts}
  end

  defp pick_language_and_lexer(lang, _highlight_info, _code) do
    case Makeup.Registry.fetch_lexer_by_name(lang) do
      {:ok, {lexer, opts}} -> {lang, lexer, opts}
      :error -> {lang, nil, []}
    end
  end

  defp render_code(lang, lexer, lexer_opts, code, opts) do
    highlight_tag = Keyword.get(opts, :highlight_tag, "span")

    highlighted =
      code
      |> unescape_html()
      |> IO.iodata_to_binary()
      |> Makeup.highlight_inner_html(
        lexer: lexer,
        lexer_options: lexer_opts,
        formatter_options: [highlight_tag: highlight_tag]
      )

    ~s(<pre><code class="makeup #{lang}">#{highlighted}</code></pre>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest) do
      [unquote(decoded) | unescape_html(rest)]
    end
  end

  defp unescape_html(<<c, rest::binary>>) do
    [c | unescape_html(rest)]
  end

  defp unescape_html(<<>>) do
    []
  end
end
