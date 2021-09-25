defmodule Ego.Template.PaginateTag do
  @moduledoc """
  Implement paginate tag similar to the one by shopify
  https://shopify.dev/api/liquid/objects/paginate
  """
  @behaviour Solid.Tag
  import NimbleParsec
  alias Solid.Parser.{Literal, Tag, Variable}

  def spec(parser) do
    space = Literal.whitespace(min: 0)

    ignore(Tag.opening_tag())
    |> ignore(space)
    |> ignore(string("paginate"))
    |> ignore(space)
    |> tag(Variable.field(), :argument)
    |> ignore(space)
    |> ignore(string("by"))
    |> ignore(space)
    |> tag(Literal.int(), :page_size)
    |> ignore(space)
    |> ignore(Tag.closing_tag())
    |> tag(parsec({parser, :liquid_entry}), :result)
    |> ignore(Tag.opening_tag())
    |> ignore(space)
    |> ignore(string("endpaginate"))
    |> ignore(space)
    |> ignore(Tag.closing_tag())
  end

  def render([argument: argument, page_size: [page_size], result: result], context, options) do
    value = Solid.Argument.get(argument, context)
    current_page = context.vars["__current_page"] || 1

    if is_list(value) and page_size > 0 do
      paginate = build_paginator(value, current_page, page_size, context.vars["current_url"])

      inner_context = %{
        context
        | vars: Map.put(context.vars, "paginate", Ego.MapHelpers.to_string_key(paginate))
      }

      {rendered, _} = Solid.render(result, inner_context, options)

      # update context so we know there more page to render
      context =
        if paginate.next.is_link do
          %{
            context
            | vars: Map.put(context.vars, "__next_page", paginate.next.page)
          }
        else
          context
        end

      {[text: rendered], context}
    else
      [text: ""]
    end
  end

  # Build paginator
  defp build_paginator(list, current_page, page_size, current_url) do
    # we should remove trailing `/page/xxx` from the url
    item_count = length(list)
    page_count = round(Float.ceil(item_count / page_size))
    current_offset = (current_page - 1) * page_size

    %{
      entries: Enum.slice(list, current_offset, page_size),
      current_offset: current_offset,
      current_page: current_page,
      total_item: item_count,
      next: %{
        is_link: current_page < page_count,
        page: current_page + 1,
        title: "Next",
        url: if(current_page < page_count, do: paginate_url(current_url, current_page + 1))
      },
      previous: %{
        is_link: current_page > 1,
        page: current_page - 1,
        title: "Previous",
        url: if(current_page > 1, do: paginate_url(current_url, current_page - 1))
      },
      page_size: page_size,
      total_page: page_count,
      parts: build_parts(page_count, current_url)
    }
  end

  defp build_parts(page_count, current_url) do
    Enum.map(1..page_count, fn page ->
      %{
        is_link: true,
        title: to_string(page),
        url: paginate_url(current_url, page),
        page: page
      }
    end)
  end

  defp paginate_url(current_url, page) do
    regex = ~r/(.*\/)page\/\d+/

    url =
      case Regex.run(regex, current_url) do
        [_, base] ->
          base

        _ ->
          current_url
      end

    if page > 1 do
      Path.join(url, "/page/#{page}")
    else
      url
    end
  end
end
