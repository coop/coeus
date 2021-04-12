defmodule Coeus.ConnectionTest do
  use ExUnit.Case, async: true

  alias Coeus.Connection

  describe "from_slice/2" do
    test "no results" do
      assert %{
               page_info: %{
                 has_previous_page: false,
                 has_next_page: false,
                 total_pages: 1,
                 total_entries: 0,
                 page: 1,
                 limit: 1
               }
             } = Connection.from_slice([], %{page: 1, limit: 1})
    end

    test "previous page exists" do
      assert %{
               page_info: %{
                 has_previous_page: true,
                 has_next_page: false,
                 total_pages: 10,
                 total_entries: 10,
                 page: 10,
                 limit: 1
               }
             } = Connection.from_slice([%{row_count: 10}], %{page: 10, limit: 1})
    end

    test "next page exists" do
      assert %{
               page_info: %{
                 has_previous_page: false,
                 has_next_page: true,
                 total_pages: 10,
                 total_entries: 10,
                 page: 1,
                 limit: 1
               }
             } = Connection.from_slice([%{row_count: 10}], %{page: 1, limit: 1})
    end

    test "both previous and next pages exist" do
      assert %{
               page_info: %{
                 has_previous_page: true,
                 has_next_page: true,
                 total_pages: 10,
                 total_entries: 10,
                 page: 2,
                 limit: 1
               }
             } = Connection.from_slice([%{row_count: 10}], %{page: 2, limit: 1})
    end
  end
end
