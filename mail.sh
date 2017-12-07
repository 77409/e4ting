#!/bin/bash

############# start ##############
# 用户名 不带 @qq.com 尾巴
smtp_u='e4ting'

# 密码 password
smtp_p='**********'

# smtp 服务器
smtp_s='smtp.qq.com'

# 用户邮箱  和上面的 用户名对应
smtp_from=${smtp_u}@qq.com

# 发送给谁，可以填多个，貌似是用逗号隔开，需要自行尝试
smtp_to='1948726847@qq.com'
###########  end  ################

mail_from=from:${smtp_from}
mail_to=To:${smtp_to}

############# start ##############
# 邮件标题
mail_sub="Subject:cdj send this mail"

# 邮件正文
mail_con="this mail is just for test ! Nothing!"
###########  end  ################

function smtp_send()
{
   # 用户名密码进行base64编码
   base64_u=$(echo -n $smtp_u | base64  -) || exit 1
   base64_p=$(echo -n $smtp_p | base64  -) || exit 1
   expect -c "
    set timeout -1
    spawn telnet $smtp_s 25
    expect {
        \"220 smtp*\"                      {send \"helo $smtp_u\r\"; exp_continue}
        \"250 smtp*\"                      {send \"auth login\r\"; exp_continue}
        \"334 VXNlcm5hbWU6*\"              {send \"$base64_u\r\"; exp_continue}
        \"334 UGFzc3dvcmQ6*\"              {send \"$base64_p\r\"; exp_continue}
        \"235 Authentication successful*\" {send \"mail from:<$smtp_from>\r\"; exp_continue}
        \"250 Ok*\"                        {send \"rcpt to:<$smtp_to>\r\"; }
        \"*\"                              {send \"quit\r\"; exit }
    }
    expect {
        \"250 Ok: queued as\"              {send \"quit\r\"; exp_continue}
        \"250 Ok*\"                        {send \"data\r\"; exp_continue}
        \"354 End data with*\"             {send \"$mail_from\r$mail_to\r$mail_sub\r\r$mail_con\r\r.\r\"; exp_continue}
        \"221 Bye*\"                       { exit }
        \"*\"                              {send \"quit\r\"; exit }
    } 
   " &> /dev/null  # 关闭交互输出，调试的时候去掉这行
}

function main()
{
   smtp_send
   
}

main

