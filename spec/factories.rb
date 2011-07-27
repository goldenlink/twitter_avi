Factory.define :user do |user|
  user.name "Daria VIOLETTE"
  user.email "d.violette@gmail.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end
