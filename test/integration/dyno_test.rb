require 'test_helper'

class DynoTest < ActionDispatch::IntegrationTest

  test "static text" do
    get "/dyno/static_text"

    assert_response :success

    assert_select 'div', 'Static text'
  end

  test 'params example' do
    get "/dyno/params_example"

    assert_response :success

    assert_select 'div', 'color:red'
  end
end
