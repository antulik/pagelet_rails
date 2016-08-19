require 'test_helper'

class PageletRails::OptionsTest < ActiveSupport::TestCase

  class A < ActionController::Base
    include PageletRails::Concerns::Options

    pagelet_options one: 1, deep_merge: { a: 'a1' }
  end

  class B < A
    pagelet_options deep_merge: { b: 'b1' }
  end

  class C < B
    pagelet_options deep_merge: { a: 'c1' }

    pagelet_options :action_specific, :action_specific_list, four: 4
  end

  test "plain value set" do
    assert_equal 1, C.new.pagelet_options.one
  end

  test "#deep_merge normal merge" do
    assert_equal(
      {'a' => 'a1', 'b' => 'b1'},
      B.new.pagelet_options.deep_merge
    )
  end

  test "#deep_merge overwrite" do
    assert_equal(
      {'a' => 'c1', 'b' => 'b1'},
      C.new.pagelet_options.deep_merge
    )
  end

  test "assignment in instance" do
    inst = A.new
    inst.pagelet_options two: 2
    assert_equal 2, inst.pagelet_options.two
  end

  test "action specific value scoped" do
    inst = C.new
    inst.action_name = 'action_specific'
    assert_equal 4, inst.pagelet_options.four
  end

  test "action specific value scoped in the list" do
    inst = C.new
    inst.action_name = 'action_specific_list'
    assert_equal 4, inst.pagelet_options.four
  end

  test "action specific value not scoped" do
    inst = C.new
    inst.action_name = 'other_action'
    assert_equal nil, inst.pagelet_options.four
  end
end
