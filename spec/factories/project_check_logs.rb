FactoryBot.define do
  factory :project_check_log do
    project nil
    check_log nil
    red_count 1
    dependency_count 1
  end
end
