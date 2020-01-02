require 'test_helper'
class Wechat::Admin::PublicTemplatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @wechat_admin_public_template = create wechat_admin_public_templates
  end

  test 'index ok' do
    get admin_public_templates_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_public_template_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('PublicTemplate.count') do
      post admin_public_templates_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_public_template_url(@wechat_admin_public_template)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_public_template_url(@wechat_admin_public_template)
    assert_response :success
  end

  test 'update ok' do
    patch admin_public_template_url(@wechat_admin_public_template), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('PublicTemplate.count', -1) do
      delete admin_public_template_url(@wechat_admin_public_template)
    end

    assert_response :success
  end

end
