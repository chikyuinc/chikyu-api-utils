require 'chikyu/sdk'
require 'io/console'
require 'json'

puts "トークンの名称を入力してください\n"
token_name = gets
token_name = token_name.chomp!

puts "メールアドレスを入力してください\n"
email = gets
email = email.chomp!

puts "パスワードを入力してください\n"
password = STDIN.noecho &:gets
password = password.chomp!

puts "トークンの有効期間(秒数)を入力してください\n"
seconds = gets
seconds = seconds.chomp!

puts "ログインしています...\n"
t = Chikyu::Sdk::SecurityToken.create token_name, email, password, seconds

puts "トークンの生成が完了しました\n"
t[:token_name] = token_name
puts "\n"
puts t.to_json
puts "\n"
