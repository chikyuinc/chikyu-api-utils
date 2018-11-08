require 'chikyu/sdk'
require 'io/console'
require 'json'

puts "メールアドレスを入力してください\n"
email = gets
email = email.chomp!

puts "パスワードを入力してください\n"
password = STDIN.noecho &:gets
password = password.chomp!

# for local server.
# Chikyu::Sdk::ApiConfig.mode = 'local'

token_name = '__temporary_token__'
puts "ログインしています...\n"
t = Chikyu::Sdk::SecurityToken.create token_name, email, password, 300

r = Chikyu::Sdk::OpenResource.invoke path: '/system/api_auth_key/for_user/create/request', data:{
  token_name: token_name,
  login_token: t[:login_token],
  login_secret_token: t[:login_secret_token]
}

puts "*********** 選択可能な組織一覧 ************"
r[:organs].each { |organ|
  puts "ID=#{organ[:organ_id]} / NAME=#{organ[:organ_name]}"
}
puts "*******************************************"
puts "対象の組織IDを入力して下さい"
organ_id = gets
organ_id = organ_id.chomp!

organ = r[:organs].find { |o|
  o[:organ_id].to_s == organ_id
}

if organ == nil
  puts "対象の組織が見つかりません"
  exit 1
end

puts "********* 選択可能なロール一覧 **************"
organ[:role_list].each { |role|
  puts "ID=#{role[:role_id]} / NAME=#{role[:role_name]}"
}
puts "*********************************************"
puts "権限を制限するためのロールIDを入力して下さい"
role_id = gets
role_id = role_id.chomp!

puts "APIキーを作成しています..."
api_key = Chikyu::Sdk::OpenResource.invoke path: '/system/api_auth_key/for_user/create/accept', data: {
  create_accept_key: r[:create_accept_key],
  organ_id: organ_id,
  role_id: role_id
}

puts "********* APIキーが生成されました ***********"
puts "\n"
puts api_key.to_json
puts "\n"

puts "ログアウトしています"
Chikyu::Sdk::SecurityToken.revoke t[:token_name], t[:login_token], t[:login_secret_token], s
puts "ログアウトしました"
