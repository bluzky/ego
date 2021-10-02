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

  def to_html({tag, _attrs, inner, _meta} = ast, fun) do
    attrs = put_anchor_id(ast)
    result = "<#{tag}#{ast_attributes_to_string(attrs)}>" <> to_html(inner, fun) <> "</#{tag}>"
    fun.(ast, result)
  end

  defp put_anchor_id({tag, attrs, inner, _meta}) do
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

  def to_text({tag, _attrs, _inner, _meta} = ast, fun) when tag in @void_elements do
    fun.(ast, "")
  end

  def to_text({_tag, _attrs, inner, %{verbatim: true}} = ast, fun) do
    inner = Enum.join(inner, "")
    result = inner <> "\n"
    fun.(ast, result)
  end

  def to_text({tag, _attrs, inner, _meta} = ast, fun) do
    result = to_text(inner, fun) <> ((need_new_line?(tag) && "\n") || "")
    fun.(ast, result)
  end

  defp need_new_line?(tag) do
    tag in ~w(h1 h2 h3 h4 h5 h6 div hr p br)
  end

  @doc """
  Build toc tree from document ast
  """
  @header_tags ~w(h1 h2 h3 h4 h5 h6)
  def extract_toc(list) when is_list(list) do
    list
    |> Enum.filter(fn {tag, _, _, _} -> tag in @header_tags end)
    |> Enum.map(fn {tag, _attrs, inner, _} ->
      text = to_text(inner)

      %{
        level: header_level(tag),
        text: text,
        id: Slug.slugify(text) |> String.slice(0, 50),
        parent_id: nil,
        children: []
      }
    end)
    |> build_tree(nil)
    |> then(&elem(&1, 0))
  end

  defp build_tree(list, last_header, acc \\ [])

  defp build_tree([header | remain], nil, acc) do
    build_tree(remain, header, acc)
  end

  defp build_tree([header | remain] = list, last_header, acc) do
    cond do
      header.level == last_header.level ->
        header = Map.put(header, :parent_id, last_header.parent_id)
        build_tree(remain, header, [last_header | acc])

      header.level - last_header.level == 1 ->
        header = Map.put(header, :parent_id, last_header.id)
        {children, remain} = build_tree(remain, header, [])
        last_header = Map.put(last_header, :children, Enum.reverse(children))
        build_tree(remain, last_header, acc)

      header.level < last_header ->
        {[last_header | acc], list}

      true ->
        build_tree(remain, last_header, acc)
    end
  end

  defp build_tree([], nil, acc), do: {Enum.reverse(acc), []}

  defp build_tree([], last_header, acc) do
    {Enum.reverse([last_header | acc]), []}
  end

  defp header_level(tag) do
    case Regex.run(~r/h(\d)/, tag) do
      [_, level] -> String.to_integer(level)
      _ -> 6
    end
  end

  @doc """
  Build html list from toc tree
  """
  def toc_to_html([]), do: nil

  def toc_to_html(list) when is_list(list) do
    lis =
      list
      |> Enum.map(fn item ->
        Enum.join(
          [
            "<li>",
            "<a href=\"\##{item.id}\">#{item.text}</a>",
            toc_to_html(item.children),
            "</li>"
          ],
          "\n"
        )
      end)
      |> Enum.join("\n")

    "<ul>#{lis}</ul>"
  end

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
