FactoryBot.define do
  
  factory :wechat_tag do
    wechat_app
    tag_id { "MyString" }
    name { "MyString" }
    count { 1 }
  end
  
end
