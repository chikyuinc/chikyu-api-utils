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

t[:token_name] = token_name
s = Chikyu::Sdk::Session.login t

puts "***** 選択可能な組織一覧 *****\n"
s.user[:organs].each {|organ|
  puts "ID=#{organ[:organ_id]} / NAME=#{organ[:organ_name]}\n"
}
puts "******************************\n"

puts "APIキーを生成する対象の組織のIDを入力してください\n"
organ_id = gets
organ_id = organ_id.chomp!

puts "組織を選択しています...\n"
s.change_organ(organ_id)

puts "生成するAPIキーの名称を入力してください\n"
api_key_name = gets
api_key_name = api_key_name.chomp!

resource = Chikyu::Sdk::SecureResource.new s

puts "ロール一覧を取得しています...\n"
organ = s.user[:organs].find { |o|
  o[:organ_id] == s.user[:organ_id]
}
if organ[:is_enabled_for_advanced_security] == 1 then 
  role_list = resource.invoke(path:'/advanced_security/role/search', data:{role_name: ''})[:roles]
else
  role_list = resource.invoke path:'/authority/role/list', data:{}
end

puts "***** 選択可能なロール一覧 *****\n"
role_list.each { |role|
  puts "ID=#{role[:_id]} / NAME=#{role[:name]}\n"
}
puts "********************************\n"

puts "APIキーに許可するロールのIDを入力してください"
role_id = gets
role_id = role_id.chomp!

puts "APIキーを生成しています...\n"
api_key = resource.invoke path: '/system/api_auth_key/create', data: {
  api_key_name: api_key_name,
  role_id: role_id
}

puts "********* APIキーが生成されました ***********"
puts "\n"
puts api_key.to_json
puts "\n"

puts "ログアウトしています"
Chikyu::Sdk::SecurityToken.revoke t[:token_name], t[:login_token], t[:login_secret_token], s
s.logout
puts "ログアウトしました"
