--[[                                    
-- by :: faeder 
-- user :: @pro_c9
-- bot :: @ll750kll_bot 
 -- CH > @Team_Faeder

- سورس فايدر V5
- ملف تعبان بي لتصير ابن كحبه وتخمط
- صعد البوت مطور بنفسه 
--]]

serpent = require("serpent")
lgi = require ('lgi')
redis = require('redis')
database = Redis.connect('127.0.0.1', 6379)
notify = lgi.require('Notify')
notify.init ("Telegram updates")
chats = {}
day = 86400
bot_id = 399096444 --put BotID -- هنا خلي ايدي بوتك
sudo_users = {259142888,399096444} --put SudoID -- هنا خلي ايدك وايدي المطورين الاضافيين
  -----------------------------------------------------------------------------------------------
                                                                                                                                       -- بدات الفكشنات --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if admin then
	    var = true
	 end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip_group(gp_id)
    local var = false
	local hashs =  'bot:vipgp:'
    local vip = database:sismember(hashs, gp_id)
	 if vip then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_gbanned(user_id)
    local var = false
	local hash = 'bot:gbanned:'
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg.sender_user_id_, msg.chat_id_)then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
  -----------------------------------------------------------------------------------------------
function del_all_msgs(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function from_username(msg)
   function gfrom_user(extra,result,success)
   if result.username_ then
   F = result.username_
   else
   F = 'nil'
   end
    return F
   end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageContact",
      contact_ = {
        ID = "Contact",
        phone_number_ = phone_number,
        first_name_ = first_name,
        last_name_ = last_name,
        user_id_ = user_id
      },
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendaction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
    end
  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false 
      end
    --------- ANTI FLOOD -------------------
	local hash = 'flood:max:warn'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 20
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:warn'..msg.chat_id_
        if not database:get(hashse) then
                if not is_mod(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:muted:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                                                 send(msg.chat_id_, msg.id_, 1, '> _💈  ايدي الدوده🆔_  *('..msg.sender_user_id_..')* \n_التكرار مقفول هنا يمطي._\nتم كتمك 🔹', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("Send INLINE KEYBOARD")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("SEND TEXT")
	msg_type = 'MSG:Text'
	-------------------------
	elseif msg.content_.ID == "MessagePhoto" then
	print("SEND PHOTO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD TO GROUP")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("JOIN TO GROUP")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("SEND STICKER")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("SEND MUSIC")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("SEND VOICE")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("SEND VIDEO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("SEND GIF")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("SEND LOCATION")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("SEND CONTACT")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
    -------------------------------------------
    -------------------------------------------
    if ((not d) and chat) then
      if msg.content_.ID == "MessageText" then
        do_notify (chat.title_, msg.content_.text_)
      else
        do_notify (chat.title_, msg.content_.ID)
      end
    end
  -----------------------------------------------------------------------------------------------
                                     -- انتهت الفكشنات --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- بدات الكودات --
  --------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
		  return 
end
if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
          delete_msg(chat,msgs)
		  return 
end
if is_gbanned(msg.sender_user_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
		   return 
end	

if database:get('bot:muteall'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return 
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
	
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, 'Your Post Views:\n> '..msg.views_..' View!', 1, 'md')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
   --vardump(msg)
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   if caption_text then
      check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
  elseif msg_type == 'MSG:Inline' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = '🔘 اهلا بك في المجموعه عزيزي 🔹{firstname} 🍄 تابع جديدنا في التطوير @team_faeder 👁‍🗨 @faeder_php 👁‍🗨'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = '🔘 اهلا بك في المجموعه عزيزي 🔹{firstname} 🍄 تابع جديدنا في التطوير @team_faeder 👁‍🗨 @faeder_php 👁‍🗨'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   if caption_text then
      check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
 if caption_text:match("@") or msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
  	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
     if caption_text:match("[\216-\219][\128-\191]") then
    if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
      check_filter_words(msg, caption_text)
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
  if caption_text:match("@") then
  if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	 if caption_text:match("[\216-\219][\128-\191]") then
    if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
      check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
      check_filter_words(msg, caption_text)
  if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
   if caption_text then
   check_filter_words(msg, caption_text)
   if caption_text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or caption_text:match("[Tt].[Mm][Ee]") or caption_text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("@") or msg.content_.entities_[0].ID and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("#") then
   if database:get('bot:hashtag:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if caption_text:match("[Hh][Tt][Tt][Pp][Ss]://") or caption_text:match("[Hh][Tt][Tt][Pp]://") or caption_text:match(".[Ii][Rr]") or caption_text:match(".[Cc][Oo][Mm]") or caption_text:match(".[Oo][Rr][Gg]") or caption_text:match(".[Ii][Nn][Ff][Oo]") or caption_text:match("[Ww][Ww][Ww].") or caption_text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if caption_text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   if caption_text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..msg.chat_id_) then
    local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end	
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPls Send Group Link.\n\nJoin My Channel > @NotTeam' and is_mod(msg.sender_user_id_, msg.chat_id_) then if text:match("(https://telegram.me/joinchat/%S+)") then 	 local glink = text:match("(https://telegram.me/joinchat/%S+)") local hash = "bot:group:link"..msg.chat_id_ database:set(hash,glink) 			 send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    check_filter_words(msg, text)
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or 
text:match("[Tt].[Mm][Ee]") or
text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   end
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
     end
    end
   end
  -------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

 -----------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  ---------------------------******** END MSG CHECKS ********--------------------------------------------
  if text == 'هلو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder = "هہ‏‏لوآت ✨🌝 شـمـعهہ‏‏ دربي 🌚🎋"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'فايدر' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder = "شـــكـــ⚔ــو 😒🚬اشــرايــد/ه🙄👿"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'بوت' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder = "آسـمـي فآيدر 😼🤘"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'باي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "وين مـولي 🐸🙁 بعدني دآضـحگ عليگ 🙆‍♂😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'احبك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "آسـف مـرتبگ بثقهہ‏‏ آمـي 🤤😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'تحبي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "آلآخ بي جفآف عآطـفي 🌝😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'اكلك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "خير شـتريد 🐸🌝❤️"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'تبادل' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "‏‏وگ حيآتي ضـيف وشـمـر خآصـ 🙊❤️🗯"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🌝' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder = "عود شـوفوني آني شـخصـيهہ‏‏ گبر لفگ 😒🤤😼"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🌝🌝' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "دييي 🤧 عود شـخصـيهہ‏‏ 🙁😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🌚' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "آوف فديت صـخآمـگ 🙊🐸😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🚶‍♀' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "شـهہ‏‏آلگمـر 🐸🗯 مـمـگن آزحفلج 🙇😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🚶' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =   "تجرآسـگمـ يتمـشـئ 🐸🗯😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🚶💔' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "خير مـضـروب بوري ? 🙇😹🗯"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'اوف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "هہ‏‏آي آلآوف مـن يآ نوع 🌝😹🗯"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'اريد بوت' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "رآسـل آلمـطـور @ll750kll_bot"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'صباح الخير' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "صـبآح آلخيرآت حيآتي 🙊❤️🗯"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'ها' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "وجعآ شـبيگ آلفآهہ‏‏ي 🐸😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😹' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "يضـحگ آلفطـير 🐸😹🗯"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😂' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "يضـحگ آلفطـير 🐸😹🐸"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😹😹' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "دومـ حيآتي 🐸🤞"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😂😂' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "فشـلتنهہ‏‏ شـبيگ تگرگر 🤤😹🗯"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😂😂😂' 

then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "شـوف آلنآسـ وين وصـلت وآنت تضـحگ 🐸😹💡"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😂😂😂😂' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "بآللهہ‏‏ ضـحگني ويآگ 🐸😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == 'مح' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "لتبوسـ لآ تزعل آلحدآيق 🤤😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '😍' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "صـعد آلحب 🙂❣"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
if text == '🤔' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
faeder =  "حيمـثل دور آلذگي وتآلي يفشـلنهہ‏‏ 🌝😹"
else 
faeder = ''
end
send(msg.chat_id_, msg.id_, 1, faeder, 1, 'md')
end
--------------------------------by faeder--------------------------------------
if text:match("^source$") or text:match("^اصدار$") or text:match("^الاصدار$") or  text:match("^السورس$") or text:match("^سورس$") then
   
   local text =  [[
مرحبا بك في سورس فايدر

📎 مطور السورس  ⛓: 

[Dev ☑️] t.me/pro_c9

 📎 تواصل المحضورين ⛓ : 

[bot 📬] t.me/ll750kll_bot

📎 قناه السورس ⛓ : 

[Ch bot 📡] t.me/team_faeder 

[Ch bot2 📡] t.me/Faeder_php
📎 كروب دعم السورس ⛓ : 

[Group link ⚡️] https://t.me/joinchat/D3I06EITFWTlJDllIjBt4g
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end
  --------------------------------------by faeder-----------------------------
  if text:match("^رابط حذف$") or text:match("^رابط الحذف$") or text:match("^اريد رابط الحذف$") or  text:match("^شمرلي رابط الحذف$") or text:match("^اريد رابط حذف$") then
   
   local text =  [[
🔘 - رابط حذف التلي 🛑 
🔘 - براحتك هو انت تطرب ع الحذف 🛑
🔘 - https://telegram.org/deactivate 🛑
🔘 - @Team_faeder 🛑
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end
  --------------------------------------------by faeder---------------------------
if text:match("^موقعي$") then
                if is_sudo(msg) then
                  t = 'مطور البوت 🛑'
                elseif is_admin(msg.sender_user_id_) then
                  t = 'ادمن البوت 🛡'
                elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
                  t = 'مدير البوت 🔊'
                elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
                  t = 'ادمن البوت 🛡'
                else
                  t = 'عظو تافه 👁‍🗨'
                end
                send(msg.chat_id_, msg.id_, 1, '🔹ايدي حسابك : '..msg.sender_user_id_..'\n🔋موقعك  : '..t, 1, 'md')
              end
  -----------------------------------------by faeder--------------------------------------------------------------
  if database:get('bot:cmds'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
  return 
  else
-------------------------------------by faeder--------------------------------------------------------------
if text:match("^ايدي$") and msg.reply_to_message_id_ == 0 then
local function getpro(extra, result, success)
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
   if result.photos_[0] then
      if is_sudo(msg) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Sudo'
      else
      t = 'مطور البوت 🛑'
      end
      elseif is_admin(msg.sender_user_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Global Admin'
      else
      t = 'ادمن البوت 🛡'
      end
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Owner'
      else
      t = 'مدير البوت 🔊'
      end
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'ادمن البوت 🛡'
      end
      else
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Member'
      else
      t = 'عظو تافه 👁‍🗨'
      end
    end
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"¶ - ايديك ?? ┇  "..msg.sender_user_id_.."\n¶ - موقعك 🛑 ┇  "..t.."\n¶ - رسائلك 🔘 ┇  "..user_msgs,msg.id_,msg.id_.."----------------\n [ @team_faeder ]")
  else
                    
       sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"¶ - ايديك 🆔 ┇  "..msg.sender_user_id_.."\n¶ - موقعك 🛑 ┇  "..t.."\n¶ - رسائلك 🔘 ┇  "..user_msgs,msg.id_,msg.id_.."----------------\n [ @team_faeder ]")
end
else 
      end
   else
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "¶ -انت لا تملك صوره لحسابك 💈┇\n\n¶ - ايديك 🆔 ┇ "..msg.sender_user_id_.."\n¶ - رسائلك  🔘 ┇ _"..user_msgs.."_---------------\n[ @team_faeder ]", 1, 'md')
   else 
  send(msg.chat_id_, msg.id_, 1, "¶ -انت لا تملك صوره لحسابك 💈┇\n\n¶ - ايديك 🆔 ┇ "..msg.sender_user_id_.."\n¶ - رسائلك  🔘 ┇ _"..user_msgs.."_---------------\n[ @team_faeder ]", 1, 'md')
end
else 
      end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
end
-------------------------------------by faeder------------------------------------------------------------
local text = msg.content_.text_:gsub('ايدي','id')
    if text:match("^[Ii][Dd] @(.*)$") then
 local ap = {string.match(text, "^([Ii][Dd]) @(.*)$")} 
 function id_by_username(extra, result, success)
 if result.id_ then
            texts = '<code>'..result.id_..'</code>'
          else 
           if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
            texts = '<code>خطا </code> ✖️'
end
    end
          send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
       resolve_username(ap[2],id_by_username)
    end
    ----------------------------by faeder-----------------------------------------------------------------
    if text:match("^[Ii][Dd]$") or text:match("^ايدي$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
   local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, ""..result.sender_user_id_.."", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  ----------------------by faeder-------------------------------------------------------------------------
if text:match('^الحساب (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^الحساب (%d+)$')
        local text = 'اضغط لمشاهده الحساب'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end 

local text = msg.content_.text_:gsub('معلومات','res')
          if text:match("^[Rr][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
            local memb = {string.match(text, "^([Rr][Ee][Ss]) (.*)$")}
            function whois(extra,result,success)
                if result.username_ then
             result.username_ = '@'..result.username_
               else
             result.username_ = 'لا يوجد معرف'
               end
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '\n> *Username* : '..result.username_..'\n> *ID* : '..msg.sender_user_id_, 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '\n📍 - المعرف ⛓ : '..result.username_..'\n📍 - الايدي 🆔 : '..msg.sender_user_id_, 1, 'md')
              end
            end
            getUser(memb[2],whois)
          end
    ------------------------------------by faeder-------------------------------------------
	local text = msg.content_.text_:gsub('اذاعه','bc')
	if text:match("^bc (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
    local gpss = database:smembers("bot:groups") or 0
	local rws = {string.match(text, "^(bc) (.*)$")} 
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'md')
  end
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Done*\n_Your Msg Send to_ `'..gps..'` _Groups_', 1, 'md')
                   else
 send(msg.chat_id_, msg.id_, 1, ' - تم نشر الرساله في '..gps..' مجموعه 👁‍🗨', 1, 'md')
end
	end
	------------------------------by faeder-----------------------------------------------------------------
	if text:match("^رفع ادمن$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
 send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _هو ادمن بالفعل 👁‍🗨️._', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
  send(msg.chat_id_, msg.id_, 1, ' - العضو *'..result.sender_user_id_..'* تم رفعه ادمن 👁‍🗨', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	----------------------------------------by faeder-------------------------------------------------------
	if text:match("^(رفع ادمن) @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(رفع ادمن) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
    texts = '<b>العضو </b><code>'..result.id_..'</code> <b>تم رفعه ادمن 👁‍🗨</b>'
            else 
            texts = '<code>لا يمكن ايجاد العضو!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],promote_by_username)
    end
	----------------------------------by faeder-------------------------------------------------------------
	if text:match("^(رفع ادمن) (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(رفع ادمن) (%d+)$")} 	
	        database:sadd('bot:mods:'..msg.chat_id_, ap[2])
   send(msg.chat_id_, msg.id_, 1, ' - العضو *'..result.sender_user_id_..'* تم رفعه ادمن 👁‍🗨', 1, 'md')
    end
	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^تنزيل ادمن$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
   send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _بالفعل ليس ادمن 👁‍🗨_', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
    send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم تنزيله عضو  👁‍🗨_', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-------------------------------------by faeder----------------------------------------------------------
	if text:match("^(تنزيل ادمن) @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local ap = {string.match(text, "^(تنزيل ادمن) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
      texts = '<b>العظو </b><code>'..result.id_..'</code> <b>تم تنزيله عضو 👁‍🗨</b>'
            else 
            texts = '<code>لا يمكن ايجاد العضو!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],demote_by_username)
    end
	---------------------------------by faeder--------------------------------------------------------------
	if text:match("^(تنزيل ادمن) (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local ap = {string.match(text, "^(تنزيل ادمن) (%d+)$")} 	
         database:srem(hash, ap[2])
	send(msg.chat_id_, msg.id_, 1, '_العظو_ *'..ap[2]..'* _تم تنزيله عضو  👁‍🗨_', 1, 'md')
    end
	--------------------------------by faeder---------------------------------------------------------------
	local text = msg.content_.text_:gsub('منع','bad')
 if text:match("^[Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
 local filters = {string.match(text, "^([Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(filters[2], 1, 50)
          database:hset('bot:filters:'..msg.chat_id_, name, 'filtered')
                if database:get('lang:gp:'..msg.chat_id_) then
    send(msg.chat_id_, msg.id_, 1, "*New Word baded!*\n--> "..name.."", 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, "🔘 - "..name.." تم اضافتها لقائمه المنع 👁‍🗨", 1, 'md')
end
 end
 ---------------------------------by faeder--------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء منع','unbad')
 if text:match("^[Uu][Nn][Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
 local rws = {string.match(text, "^([Uu][Nn][Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(rws[2], 1, 50)
          database:hdel('bot:filters:'..msg.chat_id_, rws[2])
                if database:get('lang:gp:'..msg.chat_id_) then
    send(msg.chat_id_, msg.id_, 1, ""..rws[2].." *Removed From baded List!*", 1, 'md')
else 
     send(msg.chat_id_, msg.id_, 1, " 🔘 - "..rws[2].." تم حذفها من قائمه المنع 👁‍🗨", 1, 'md')
end
 end 
 -------------------------------------by faeder----------------------------------------------------------
 if text:match("^وضع ترحيب (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
 local welcome = {string.match(text, "^(وضع ترحيب) (.*)$")} 
  send(msg.chat_id_, msg.id_, 1, '🔘 - تم وضع الترحيب 👁‍🗨 :\n\n'..welcome[2]..'', 1, 'md')
   database:set('welcome:'..msg.chat_id_,welcome[2])
 end

          local text = msg.content_.text_:gsub('حذف الترحيب','del wlc')
 if text:match("^[Dd][Ee][Ll] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Deleted!*', 1, 'md')
       else 
     send(msg.chat_id_, msg.id_, 1, '🔘 - تم حذف الترحيب 👁‍🗨', 1, 'md')
end
   database:del('welcome:'..msg.chat_id_)
 end
 
          local text = msg.content_.text_:gsub('جلب الترحيب','get wlc')
 if text:match("^[Gg][Ee][Tt] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
 local wel = database:get('welcome:'..msg.chat_id_)
 if wel then
send(msg.chat_id_, msg.id_, 1, '🔘 - الترحيب  👁‍🗨 :'..wel, 1, 'md')
    else 
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'Welcome msg not saved!', 1, 'md')
else 
      send(msg.chat_id_, msg.id_, 1, '🔘 - لم يتم وضع ترحيب للمجموعه 👁‍🗨', 1, 'md')
end
 end
 end
 -----------------------------------------by faeder------------------------------------------------------
 if text:match("^فعل الترحيب$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '🔘 - تم تفعيل الترحيب  👁‍🗨', 1, 'md')
   database:set("bot:welcome"..msg.chat_id_,true)
 end
 if text:match("^عطل الترحيب$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '🔘 - تم تعطيل الترحيب  👁‍🗨', 1, 'md')
   database:del("bot:welcome"..msg.chat_id_)
 end
 -------------------------------------by faeder----------------------------------------------------------
	if text:match("^حظر$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, '*لا يمكنك حظر او طرد المدراء او الادمنيه 👁‍🗨*', 1, 'md')
    else
    if database:sismember(hash, result.sender_user_id_) then
   send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم حظره 👁‍🗨_', 1, 'md')
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
    send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم حظره 👁‍🗨_', 1, 'md')
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^(حظر) @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(حظر) @(.*)$")} 
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*لا يمكنك حظر او طرد المدراء او الادمنيه 👁‍🗨*', 1, 'md')
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
texts = '<b>العظو </b><code>'..result.id_..'</code> <b>تم حظره 👁‍🗨</b>'
		 chat_kick(msg.chat_id_, result.id_)
	end
            else 
            texts = '<code>لا يمكن ايجاد العضو!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],ban_by_username)
    end
	--------------------------------------by faeder---------------------------------------------------------
	if text:match("^(حظر) (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(حظر) (%d+)$")}
	if is_mod(ap[2], msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, '*لا يمكنك حظر او طرد المدراء او الادمنيه 👁‍🗨*', 1, 'md')
    else
	        database:sadd('bot:banned:'..msg.chat_id_, ap[2])
		 chat_kick(msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..ap[2]..'* _تم حظره 👁‍🗨_', 1, 'md')
	end
    end
	---------------------------------------by faeder--------------------------------------------------------
local text = msg.content_.text_:gsub('حذف الكل','delall')
 if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
 function delall_by_reply(extra, result, success)
 if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
       send(msg.chat_id_, msg.id_, 1, '🔘 - لا تستطيع حذف رسائل الادمنيه والمدراء 👁‍🗨', 1, 'md')
end
else
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..result.sender_user_id_..'* _Has been deleted!!_', 1, 'md')
       else
   send(msg.chat_id_, msg.id_, 1, '🔘 - العضو *'..result.sender_user_id_..'* تم حذف كل رسائله 👁‍🗨', 1, 'md')
end
       del_all_msgs(result.chat_id_, result.sender_user_id_)
    end
 end
       getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
    end
	---------------------------------------by faeder--------------------------------------------------------
	if text:match("^(الغاء حظر)$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
   send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _هو غير محظور 👁‍🗨_', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
    send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم الغاء حظره 👁‍🗨_', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	---------------------------------------by faeder--------------------------------------------------------
	if text:match("^(الغاء حظر) @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(الغاء حظر) @(.*)$")} 
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
   text = '<b>العضو </b><code>'..result.id_..'</code> <b>تم الغاء حظره 👁‍🗨</b>'
            else 
        texts = '<لا يمكن ايجاد العضو!</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	      resolve_username(ap[2],unban_by_username)
    end
	--------------------------------------by faeder---------------------------------------------------------
	if text:match("^(الغاء حظر) (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(الغاء حظر) (%d+)$")} 	
	        database:srem('bot:banned:'..msg.chat_id_, ap[2])
                     send(msg.chat_id_, msg.id_, 1, '*لا يمكنك طرد المدراء ✖️!!*', 1, 'md')      
    end
	--------------------------------------by faeder---------------------------------------------------------
	if text:match("^كتم") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_لايمكنك كتم المدير او المشرف 👁‍🗨_', 1, 'md')
    else
    if database:sismember(hash, result.sender_user_id_) then
    send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _بالفعل تم كتمه 👁‍🗨_', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
  send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تـم كتمه 👁‍🗨_', 1, 'md')
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-------------------------------------by faeder----------------------------------------------------------
	if text:match("^(كتم) @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(كتم) @(.*)$")} 
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_لايمكنك كتم المدير او المشرف 👁‍🗨_', 1, 'md')
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
    texts = '<b>العضو</b><code>'..result.id_..'</code> <b>تم كتمه 👁‍🗨</b>'
		 chat_kick(msg.chat_id_, result.id_)
	end
            else 
            texts = '<code>لا يمكن ايجاد العضو!</code>'   
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],mute_by_username)
    end
	-----------------------------------by faeder------------------------------------------------------------
	if text:match("^(كتم) (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(كتم) (%d+)$")}
	if is_mod(ap[2], msg.chat_id_) then
     send(msg.chat_id_, msg.id_, 1, '_لايمكنك كتم المدير او المشرف 👁‍🗨_', 1, 'md')
    else
	        database:sadd('bot:muted:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..ap[2]..'* _تم كتمه 👁‍🗨_', 1, 'md')
	end
    end
	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^الغاء الكتم") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _غير مكتوم فعلا 👁‍🗨_', 1, 'md')
	else
         database:srem(hash, result.sender_user_id_)
  send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم الغاء كتمه👁‍🗨_', 1, 'md')
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^الغاء الكتم @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(الغاء الكتم) @(.*)$")} 
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
     text = '<b>العضو </b><code>'..result.id_..'</code> <b>تم الغاء كتمه 👁‍🗨</b>'
            else 
              text = '<code>لا يمكن ايجاد العضو✖️</code>'   
    end
	         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	      resolve_username(ap[2],unmute_by_username)
    end
    -------------------------------------by faeder------------------------------------------------------
	if text:match("^(الغاء الكتم) (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(الغاء الكتم)) (%d+)$")} 	
	        database:srem('bot:muted:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..ap[2]..'* _تم الغاء كتمه👁‍🗨 _', 1, 'md')     
    end
	----------------------------------------by faeder-------------------------------------------------------
	if text:match("^(رفع مدير)$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
 send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _هو مدير الكروب فعلا 👁‍🗨_', 1, 'md')
	else
         database:sadd(hash, result.sender_user_id_)
            send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم رفع مدير للكروب ✔️._', 1, 'md')      
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	--------------------------------------by faeder---------------------------------------------------------
	if text:match("^(رفع مدير) @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(رفع مدير) @(.*)$")} 
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
                texts = '<b>العضو </b><code>'..result.id_..'</code> <b>تم رفع مدير للكروب ✔️.!</b>'
            else 
            texts = '<code>لا يمكن ايجاد العضو</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],setowner_by_username)
    end
	-------------------------------------by faeder----------------------------------------------------------
	if text:match("^(رفع مدير) (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local ap = {string.match(text, "^(رفع مدير) (%d+)$")} 	
	        database:sadd('bot:owners:'..msg.chat_id_, ap[2])
	send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..ap[2]..'* _تم رفع مدير للكروب ✔️._', 1, 'md')   
    end
	-----------------------------------------by faeder------------------------------------------------------
	if text:match("^تنزيل مدير$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _هو ليس مدير سابقا ✖️._', 1, 'md')  
	else
         database:srem(hash, result.sender_user_id_)
             send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..result.sender_user_id_..'* _تم تنزله مدير من الكروب ✔️._', 1, 'md')    
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
    end
	-------------------------------------by faeder----------------------------------------------------------
	if text:match("^(تنزيل مدير) @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local ap = {string.match(text, "^(تنزيل مدير) @(.*)$")} 
	function remowner_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
    texts = '<b>العضو </b><code>'..result.id_..'</code> <b>تم تنزله مدير من الكروب ✔️</b>'
            else 
             texts = '<code>لا يمكن ايجاد العضو✖️</code>'
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remowner_by_username)
    end
	--------------------------------by faeder---------------------------------------------------------------
	if text:match("^(تنزيل مدير) (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local ap = {string.match(text, "^(تنزيل مدير) (%d+)$")} 	
         database:srem(hash, ap[2])
send(msg.chat_id_, msg.id_, 1, '_العضو_ *'..ap[2]..'* _تم تنزله مدير من الكروب ✔️._', 1, 'md')
    end
	------------------------------------by faeder-----------------------------------------------------------
   if text:match("^تثبيت$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
	send(msg.chat_id_, msg.id_, 1, 'تم  تثبيت الرساله 🛑', 1, 'md')
   end
   ----------------------------by faede-------------------------------------------------------------------
   if text:match("^الغاء تثبيت$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
        send(msg.chat_id_, msg.id_, 1, 'تم الغاء تثبيت 👁‍🗨', 1, 'md')
   end
   ------------------------------by faeder-----------------------------------------------------------------
   if text:match("^اعاده تثبيت$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
local pin_id = database:get('pinnedmsg'..msg.chat_id_)
        if pin_id then
         pin(msg.chat_id_,pin_id,0)
         send(msg.chat_id_, msg.id_, 1, '*تم اعاده تثبيت الرساله 👁‍🗨*', 1, 'md')
		else
         send(msg.chat_id_, msg.id_, 1, "*i Can't find last pinned msgs...*", 1, 'md')
		 end
   end

	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^المكتومين") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<b>قائمه المكتومين 🚀</b>\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('العضو:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
       text = "لا يوجد مكتومين ✖️"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------by faeder------------------------------------------------------
	if text:match("^المدير$") or text:match("^المدراء$") then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<b>مدراء المجموعه 🚀</b>\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
    text = "لا يوجد مدير 🚀"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------by faeder------------------------------------------------------------
	if text:match("^المحظورين$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
	local text = "<b>قائمه المحظورين  🚀</b>\n\n"
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
  text = "لا يوجد محظورين 🚀"
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^الادمنيه$") then
    local hash =  'bot:mods:'..msg.chat_id_
 local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Mod List:</b>\n\n"
else 
  text = "قائمه الادمنيه 🚀 :\n\n"
  end
 for k,v in pairs(list) do
 local user_info = database:hgetall('user:'..v)
  if user_info and user_info.username then
   local username = user_info.username
   text = text..k.." - @"..username.." ["..v.."]\n"
  else
   text = text..k.." - "..v.."\n"
  end
 end
 if #list == 0 then
    if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "لا يوجد ادمنيه 🚀"
end
    end
 send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end
    ------------------------------------by faeder-----------------------------------------------------------
  if text:match("^طرد$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
             send(msg.chat_id_, msg.id_, 1, '*لا تستطيع طرد الادمنيه او المدراء ✖️!!*', 1, 'md')   
    else
   send(msg.chat_id_, msg.id_, 1, 'العضو '..result.sender_user_id_..' تم طرده 👁‍🗨', 1, 'html')
        chat_kick(result.chat_id_, result.sender_user_id_)
        end
	end
   getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
    end
    ----------------------------------by faeder-------------------------------------------------------------
  if text:match("^اضافه") and msg.reply_to_message_id_ and is_sudo(msg) then
      function inv_reply(extra, result, success)
           add_user(result.chat_id_, result.sender_user_id_, 5)
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
    end
	---------------------------------------by faeder--------------------------------------------------------
local text = msg.content_.text_:gsub('حظر عام','banall')
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll]$") and is_sudo(msg) and msg.reply_to_message_id_ then
            function gban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
	if is_admin(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, 'لا تستطيع حظر ادمنيه البوت والمطورين عام ✖️', 1, 'md')            
end
    else
              database:sadd(hash, result.sender_user_id_)
              chat_kick(result.chat_id_, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Banned !</b>'
                else
   texts = ' <code>العضو </code>'..result.sender_user_id_..'<code> تم حظره عام</code>👁‍🗨'
end
end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,gban_by_reply)
          end
          -------------------------------by faeder----------------------------------------------------------------
        local text = msg.content_.text_:gsub('الغاء العام','unbanall')
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]$") and is_sudo(msg) and msg.reply_to_message_id_ then
            function ungban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
              if database:get('lang:gp:'..msg.chat_id_) then
                  
     texts =  ' <code>العضو '..result.sender_user_id_..' تم الغاء حظره من العام </code> 👁‍🗨'
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
              database:srem(hash, result.sender_user_id_)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ungban_by_reply)
          end
          ----------------------------------by faeder-------------------------------------------------------------
if text:match("^قائمه المنع$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:filters:'..msg.chat_id_
      if hash then
         local names = database:hkeys(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>bad List:</b>\n\n"
else 
text = "<code>قائمه الكلمات الممنوعه </code>🚀 :\n\n"
  end    for i=1, #names do
      text = text..'> `'..names[i]..'`\n'
    end
	if #names == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>bad List is empty !</b>"
              else 
   text = "<code>لا يوجد كلمات ممنوعه</code> 🚀"
end
    end
		  send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
       end 
    end
    ------------------------------------by faede-----------------------------
    if text:match("^م5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[
• اهلا بك في قائمةه الاوامر المطور 🛑 •
 
ֆ - - - - - - - - - - - - ֆ
- تفعيل // لتفعيل البوت ✔️ •
- تعطيل // لتعطيل البوت 🍥 •

- شحن مده // عدد التوقيت لبوت في لمجموعه 📊 •
- تغيير المدة + المدة // لتغييرها 📬 •

- المده مفتوحه // لتفعيل البوت مدى الحياة 🔥•
- اذاعه // لنشر رسالة في جميع المجموعات الخاصةه بالبوت ⚡️ •

- حظر عام // لحظر الشخص من جميع المجموعات 📤 •
- الغاء العام // لالغاء حظر العام 💭 •

- قائمه العام // لعرض قائمه العام 💬  •
- مغادره او طرد بالرد // لمغادرة البوت ✨ •

- فعل الردود // لتفعيل ااردود في المجموعةه 🍥 •
- عطل الردود // لتوقيف الردود في المجموعةه 🕸 •

- فعل الترحيب // لتفعيل الترحيب في المجموعةه 🌪 •
- عطل الترحيب // لتعطيل الترحيب في المجموعةه 🌾 •

- وضع الترحيب // لوضع ترحيب للمجموعةه ☔️ •
- حذف الترحيب // لحذف ترحيب المجموعةه 💧•

- جلب الترحيب // لجلب ترحيب المجموعةه 🌪 •
تنظيف + العدد // لمسح الرسائل المطلوبة 📈 •
ֆ - - - - - - - - - - - - ֆ
• اكتب السورس لعرض معلومات البوت 🔸
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
	-----------------------------------by faeder------------------------------------------------------------
  if msg.content_.text_:match("^قائمه العام$") and is_sudo(msg) then
    local hash =  'bot:gbanned:'
    local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Gban List:</b>\n\n"
else 
text = "<code>قائمه الحظر العام </code>🚀 :\n\n"
end	
for k,v in pairs(list) do
    local user_info = database:hgetall('user:'..v)
    if user_info and user_info.username then
    local username = user_info.username
      text = text..k.." - @"..username.." ["..v.."]\n"
      else
      text = text..k.." - "..v.."\n"
          end
end
            if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Gban List is empty !</b>"
              else 
        text = "<code>لا يوجد محظورين عام</code> 🚀"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
          -----------------------------by faeder------------------------------------------------------------
          if text:match("^م4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[
• اهلا بك في قائمةه الاوامر الاخرى 📬 •
ֆ - - - - - - - - - - - - ֆ

- موقعي // لعرض رتبتك في المجموعةه ⚠️ •
- ايدي // لعرض ايديك وايدي المجموعةه ⚡️ •

- الحساب + الايدي // لعرض حساب الشخص ☄ •
- ايدي بالرد او المعرف // لعرض معلومات المستخدم وايديةه ✨ •

- معلومات بالمعرف // لعرض معلومات الشخص المطلوب 🌙 •

- السورس // لعرض اصدار السورس ✅  •
- المطور // لعرض المطور ♻️ •

- الادمنيه // لعرض الادمنيه في البوت 🌐 •
- المدراء // لعرض المدراء في البوت 🔘 •

- رابط حذف // لعرض رابط الحذف ⚠️ •
- الرابط // لعرض رابط المجموعةه ☑️ •

- رسائلي // لعرض عدد رسائلك 🚸 •
- القوانين // لاضهار القوانين 💭 •
ֆ - - - - - - - - - - - - ֆ
• اكتب السورس لعرض معلومات البوت 🔸
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
	----------------------------------by faeder-------------------------------------------------------------
	if text:match("^(قفل) (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^(قفل) (.*)$")} 
      if lockpt[2] == "التعديل" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* التعديل✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل التعديل ❈ *', 1, 'md')
         database:set('editmsg'..msg.chat_id_,'delmsg')
	  end
	  if lockpt[2] == "البوتات" then
send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* البوتات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل البوتات ❈ *', 1, 'md')
         database:set('bot:bots:mute'..msg.chat_id_,true)
      end
	  if lockpt[2] == "التكرار" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* التكرار✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل التكرار ❈ *', 1, 'md')
         database:del('anti-flood:'..msg.chat_id_)
	  end
	  if lockpt[2] == "التثبيت" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* التثبيت✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل التثبيت ❈ *', 1, 'md')
	     database:set('bot:pin:mute'..msg.chat_id_,true)
      end
	end
	----------------------------------by faeder---------------------------
	if text:match("^م3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[
• اهلا بك في قائمة اوامر اعدادات المجموعه 📈 •

ֆ - - - - - - - - - - - - ֆ

- مسح المحظورين // لمسح المحظورين من المجموعه ⚡️ •
- مسح البوتات // لطرد جميع البوتات من المجموعةه ☑️ •

- مسح الادمنيه // لمسح الادمنيه من البوت 🌙 •
- مسح المدراء // لمسح المدراء من البوت 📬 •

- مسح القوانين // لمسح القوانين من لمجموعه ⚠️ •
- مسح المكتومين // لمسح المكتومين ⏱ •

- مسح قائمه المنع // لمسح الكلمات الممنوعه 🚀 •
- مسح الرابط // لمسح الرابط 💡 •

- ضع صوره // لتغيير الصورة 🎙 •
- وضع قوانين // لوضع قوانين 🔊 •

- ضع اسم + الاسم // لتغيير الاسم 🖱 •
- وضع رابط // لوضع رابط 📡 •

- منع + الكلمه // لمنع الكلمه في المجموعةه💧•
- الغاء منع + الكلمه // لالغاء منع الكلام 📈 •

-قائمه المنع // لعرض الكلمات الممنوعةه 🚸 •

- المكتومين // لعرض المكتومين 📡 •
- المحظورين // لعرض المحظورين في لبوت ⏱ •

- اضافه + المعرف // للاضافة ❕ •
- كرر // لتكرار الرسالة ✔️ •

- تثبيت // لتثبيت الرسالةه ✅ •
- الغاء تثبيت // لمسح المثبت 🔬 •

- حذف الكل // لحذف جميع رسائل الشخص المطلوب 📡 •
ֆ - - - - - - - - - - - - ֆ
• اكتب السورس لعرض معلومات البوت 🔸
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
       end
	----------------------------------by faeder-------------------------------------------------------------
  	if text:match("^(فتح) (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^(فتح) (.*)$")} 
      if unlockpt[2] == "التعديل" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* التعديل✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح التعديل ❈ *', 1, 'md')

         database:del('editmsg'..msg.chat_id_)
      end
	  if unlockpt[2] == "البوتات" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* البوتات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح البوتات ❈ *', 1, 'md')
         database:del('bot:bots:mute'..msg.chat_id_)
      end
	  if unlockpt[2] == "التكرار" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* التكرار✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح التكرار ❈ *', 1, 'md')
         database:set('anti-flood:'..msg.chat_id_,true)
	  end
	  if unlockpt[2] == "التثبيت" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* التثبيت✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح التثبيت ❈ *', 1, 'md')
	     database:del('bot:pin:mute'..msg.chat_id_)
      end
    end
    ---------------------------------by faeder---------------------------------
    if text:match("^م2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[
• اهلا بك عزيزي ⚡️ في قائمه اوامر الحمايةه ⚠️ •

- استخدم قفل للقفل 🔐 -
- استخدم فتح للفتح 🔓 -

ֆ - - - - - - - - - - - - ֆ

- التعديل ⚡️ •
- البوتات 🔖 •

- التكرار 🌟 •
- التثبيت 🔥 •

- الدردشه ☄ •
- الاونلاين 🌪 •

- الفيديو 📊 •
- الصور 🖱 •

- المتحركه 🍥 •
- الاغاني 🌾 •

- الصوتيات 🕸 •
- الروابط 🌙 •

- الشبكات ⚠️ •
- المعرف❕•

- الجهات ♻️ •
- الهشتاك ♦️ •

- العربيه 🚸 •
- الانكليزيه 💭 •

- الملصقات 📬 •
- التوجيه 📡  •

ֆ - - - - - - - - - - - - ֆ
• اكتب السورس لعرض معلومات البوت 🔸
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
	-------------------------------by faeder----------------------------------------------------------------
  if text:match("^(قفل) (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^(قفل) (.*)$")} 
     
	  if mutept[2] == "الدردشه" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الدردشه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الدردشه ❈ *', 1, 'md')
         database:set('bot:text:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الاونلاين" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الاونلاين✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الاونلاين ❈ *', 1, 'md')
         database:set('bot:inline:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الصور" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الصور✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الصور ❈ *', 1, 'md')
         database:set('bot:photo:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الفيديو" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الفيديو✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الفيديو ❈ *', 1, 'md')
         database:set('bot:video:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "المتحركه" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* المتحركه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل المتحركه ❈ *', 1, 'md')
         database:set('bot:gifs:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الاغاني" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الاغاني✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الاغاني ❈ *', 1, 'md')
         database:set('bot:music:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الصوتيات" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الصوتيات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الصوتيات ❈ *', 1, 'md')
         database:set('bot:voice:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الروابط" then
      send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الروابط✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الروابط ❈ *', 1, 'md')
         database:set('bot:links:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الشبكات" then
  send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الشبكات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الشبكات ❈ *', 1, 'md')
         database:set('bot:location:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "المعرف" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* المعرف✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل المعرف ❈ *', 1, 'md')
         database:set('bot:tag:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الجهات" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الجهات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الجهات ❈ *', 1, 'md')
         database:set('bot:contact:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الهشتاك" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الهشتاك✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الهشتاك ❈ *', 1, 'md')
         database:set('bot:webpage:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "العربيه" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* العربيه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل العربيه ❈ *', 1, 'md')
         database:set('bot:arabic:mute'..msg.chat_id_,true)
      end
	  if mutept[2] == "الانكليزيه" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* اللانكليزيه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الانكليزيه ❈ *', 1, 'md')
         database:set('bot:english:mute'..msg.chat_id_,true)
      end 
	  if mutept[2] == "الملصقات" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* الملصقات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل الملصقات ❈ *', 1, 'md')
         database:set('bot:sticker:mute'..msg.chat_id_,true)
      end 
	  if mutept[2] == "التوجيه" then
  send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم قفل_* التوجيه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ قفل التوجيه ❈ *', 1, 'md')
         database:set('bot:forward:mute'..msg.chat_id_,true)
      end
	end
	--------------------------------------by faeder--------------------------------------------------------
	if text:match("^م1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[
• اهلا بك في قائمةه الاوامر الحظر والرفع 💈 •
 
ֆ - - - - - - - - - - - - ֆ
- رفع مدير // الرد + الايدي + الرد 🔊 •
- تنزيل مدير // الرد + الايدي + الرد 🏷 •

- رفع ادمن // بلايدي + المعرف + الرد 📬 •
- تنزيل ادمن // ايدي + معرف + الرد ☑️ •

- كتم // بالمعرف او الايدي او الرد لكتم الشخص 🖱•
- الغاء الكتم // بالمعرف او الايدي او الرد🖱•

- حظر // بالمعرف او الايدي او الرد لحظر الشخص 🔥 •
- الغاء الحظر // الايدي + معرف + الرد 📬 •

- طرد // لطرد العضو 🔖 • 
ֆ - - - - - - - - - - - - ֆ
• اكتب السورس لعرض معلومات البوت 🔸
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
	--------------------------------------by faeder---------------------------------------------------------
  	if text:match("^(فتح) (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^(فتح) (.*)$")} 
      if unmutept[2] == "الدردشه" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الدردشه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الدردشه ❈ *', 1, 'md')
         database:del('bot:text:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الصور" then
  send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الصور✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الصور ❈ *', 1, 'md')
         database:del('bot:photo:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الفيديو" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الفيديو✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الفيديو ❈ *', 1, 'md')
         database:del('bot:video:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الاونلاين" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الاونلاين✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الاونلاين ❈ *', 1, 'md')
         database:del('bot:inline:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "المتحركه" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* المتحركه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح المتحركه ❈ *', 1, 'md')
         database:del('bot:gifs:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الاغاني" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الاغاني✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الاغاني ❈ *', 1, 'md')
         database:del('bot:music:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الصوتيات" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الصوتيات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الصوتيات ❈ *', 1, 'md')
         database:del('bot:voice:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الروابط" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الروابط✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الروابط ❈ *', 1, 'md')
         database:del('bot:links:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الشبكات" then
  send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الشبكات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الشبكات ❈ *', 1, 'md')
         database:del('bot:location:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "المعرف" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* المعرف✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح المعرف ❈ *', 1, 'md')
         database:del('bot:tag:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الهشتاك" then
     send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الهشتاك✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الهشتاك ❈ *', 1, 'md')
         database:del('bot:hashtag:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الجهات" then
send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الجهات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الجهات ❈ *', 1, 'md')
         database:del('bot:contact:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "العربيه" then
    send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* العربيه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح العربيه ❈ *', 1, 'md')
         database:del('bot:arabic:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الانكليزيه" then
   send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الانكليزيه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الانكليزيه ❈ *', 1, 'md')
         database:del('bot:english:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "الملصقات" then
send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* الملصقات✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح الملصقات ❈ *', 1, 'md')
         database:del('bot:sticker:mute'..msg.chat_id_)
      end
	  if unmutept[2] == "التوجيه" then
  send(msg.chat_id_, msg.id_, 1, '_❅【📍 تم فتح_* التوجيه✔️ 】 ✹\n\n❅ ¦╗ الامر ╔↜❈ فتح التوجيه ❈ *', 1, 'md')
         database:del('bot:forward:mute'..msg.chat_id_)
      end 
	end
	----------------------by faeder-------------------------
	if text:match("^الاوامر$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text = [[
• اهلا بك عزيزي في قائمةه الاوامر 🔱 •

@Team_Faeder
ֆ • • • • • • • • • • • • • ֆ
• م1 - لاضهار اوامر الرفع  .... 💭 -
• م2 - لاضهار اوامر الحمايه .... 🌪 -

• م3 - لاضهار اوامر الاعدادات ... 🏴 -
• م4 - لاضهار اوامر اخرى ... ✅ -

• م5 - لاضهار اوامر المطور .... 📃 -

ֆ • • • • • • • • • • • • • ֆ
• اكتب السورس لعرض معلومات البوت 🔸
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
	------------------------------------------by faeder-----------------------------------------------------
if text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^وضع رابط$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         database:set("bot:group:link"..msg.chat_id_, 'Waiting For Link!\nPls Send Group Link')
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Please Send Group Link Now!*', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '🔘 - قم بارسال الرابط ليتم حفظه 💈', 1, 'md')
end
 end
 --------------------------------------------by faeder---------------------------------------------------
 if text:match("^[Ll][Ii][Nn][Kk]$") or text:match("^الرابط$") then
 local link = database:get("bot:group:link"..msg.chat_id_)
   if link then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '<b>Group link:</b>\n'..link, 1, 'html')
       else 
                  send(msg.chat_id_, msg.id_, 1, '🔘 - <code>رابط المجموعه 🏮 :</code>\n'..link, 1, 'html')
end
   else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*There is not link set yet. Please add one by #setlink .*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '🔘 - لم يتم حفظ رابط ارسل [ وضع رابط ] لحفظ رابط جديد ✔️', 1, 'md')
end
   end
  end
	---------------------------------------by faeder--------------------------------------------------------
  	if text:match("^المعرف$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	          send(msg.chat_id_, msg.id_, 1, '*'..from_username(msg)..'*', 1, 'md')
    end
	---------------------------------------by faeder--------------------------------------------------------
  	local text = msg.content_.text_:gsub('مسح','clean')
   if text:match("^[Cc][Ll][Ee][Aa][Nn] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
 local txt = {string.match(text, "^([Cc][Ll][Ee][Aa][Nn]) (.*)$")} 
       if txt[2] == 'banlist' or txt[2] == 'Banlist' or txt[2] == 'المحظورين' then
       database:del('bot:banned:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Banlist has been_ *Cleaned*', 1, 'md')
        else 
         send(msg.chat_id_, msg.id_, 1, '_> تم تنظيف_ *قائمه المحظورين✔️*', 1, 'md')
end
       end
    if txt[2] == 'bots' or txt[2] == 'Bots' or txt[2] == 'البوتات' then
   local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].msg.sender_user_id_)
          end 
      end
    channel_get_bots(msg.chat_id_,g_bots) 
    if database:get('lang:gp:'..msg.chat_id_) then
           send(msg.chat_id_, msg.id_, 1, '_> All bots_ *kicked!*', 1, 'md')
          else 
          send(msg.chat_id_, msg.id_, 1, '_> تم ازاله_ *البوتات✔️*', 1, 'md')
end
 end
    if txt[2] == 'modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'الادمنيه' and is_owner(msg.sender_user_id_, msg.chat_id_) then
       database:del('bot:mods:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Modlist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, '_> تم ازاله_ *الادمنيه✔️*', 1, 'md')
end
       end 
    if txt[2] == 'owners' and is_sudo(msg) or txt[2] == 'Owners' and is_sudo(msg) or txt[2] == 'المدراء' and is_sudo(msg) then
       database:del('bot:owners:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> ownerlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '_> تم ازاله_ *المدراء ✔️*', 1, 'md')
end
       end
    if txt[2] == 'rules' or txt[2] == 'Rules' or txt[2] == 'القوانين' then
       database:del('bot:rules'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> rules has been_ *Cleaned*', 1, 'md')
        else 
              send(msg.chat_id_, msg.id_, 1, '_> تم مسح_ *القوانين✔️*', 1, 'md')
end
       end
    if txt[2] == 'link' or  txt[2] == 'Link' or  txt[2] == 'الرابط' then
       database:del('bot:group:link'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> link has been_ *Cleaned*', 1, 'md')
        else 
             send(msg.chat_id_, msg.id_, 1, '_> تم مسح_ *الرابط المحفوظ✔️*', 1, 'md')
end
       end
    if txt[2] == 'badlist' or txt[2] == 'Badlist' or txt[2] == 'قائمه المنع' then
       database:del('bot:filters:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> badlist has been_ *Cleaned*', 1, 'md')
        else 
              send(msg.chat_id_, msg.id_, 1, '_> تم مسح_ *قائمه المنع✔️*', 1, 'md')
end
       end
    if txt[2] == 'silentlist' or txt[2] == 'Silentlist' or txt[2] == 'المكتومين' then
       database:del('bot:muted:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> silentlist has been_ *Cleaned*', 1, 'md')
        else 
                send(msg.chat_id_, msg.id_, 1, '_> تم مسح_ *قائمه الكتم ✔️*', 1, 'md')
end
       end
       
    end
	---------------------------------by faeder--------------------------------------------------------------
  	 if text:match("^الاعدادات$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`[مفعل🌺 | 🔐]`'
	else
	mute_all = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`[مفعل | 🔐]`'
	else
	mute_text = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`[مفعل | 🔐]`'
	else
	mute_photo = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`[مفعل | 🔐]`'
	else
	mute_video = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`[مفعل | 🔐]`'
	else
	mute_gifs = '`[معطل | 🔓]`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`[مفعل | 🔓]`'
	else
	mute_flood = '`[معطل | 🔐]`'
	end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 5
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
	end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 3
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`[مفعل | 🔐]`'
	else
	mute_music = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`[مفعل | 🔐]`'
	else
	mute_bots = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`[مفعل | 🔐]`'
	else
	mute_in = '`[معطل | 🔓]`'
	end
	------------
	if database:get('bot:cmds'..msg.chat_id_) then
	mute_cmd = '[غیر فعال|⭕]'
	else
	mute_cmd = '[فعال|✔]'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`[مفعل | 🔐]`'
	else
	mute_voice = '`[معطل | 🔓]`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`[مفعل | 🔐]`'
	else
	mute_edit = '`[معطل | 🔓]`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`[مفعل | 🔐]`'
	else
	mute_links = '`[معطل | 🔓]`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`[مفعل | 🔐]`'
	else
	lock_pin = '`[معطل | 🔓]`'
	end 
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`[مفعل | 🔐]`'
	else
	lock_sticker = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`[مفعل | 🔐]`'
	else
	lock_tgservice = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`[مفعل | 🔐]`'
	else
	lock_wp = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`[مفعل | 🔐]`'
	else
	lock_htag = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`[مفعل | 🔐]`'
	else
	lock_tag = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`[مفعل | 🔐]`'
	else
	lock_location = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`[مفعل | 🔐]`'
	else
	lock_contact = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`[مفعل | 🔐]`'
	else
	lock_english = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`[مفعل | 🔐]`'
	else
	lock_arabic = '`[معطل | 🔓]`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`[مفعل | 🔐]`'
	else
	lock_forward = '`[معطل | 🔓]`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '[فعال|✔]'
	else
	send_welcome = '[غیر فعال|⭕]'
	end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = 'مفعله'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
 local TXT = "- `اعدادات المجموعه `\n$================$\n - `كل الوسائط` : "..mute_all.."\n"
	 .."- `الروابط` : "..mute_links.."\n" 
	 .."- `الاونلاين` : "..mute_in.."\n"
	 .."- `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."- `اعاده التوجيه` : "..lock_forward.."\n" 
	 .."- `اللغه العربيه` : "..lock_arabic.."\n"
	 .."- `التاك` : "..lock_htag.."\n"
	 .."- `المعرف` : "..lock_tag.."\n" 
	 .."- `المواقع` : "..lock_wp.."\n\n" 
	 .."- `الشبكات` : "..lock_location.."\n"
   .."- `الصور` : "..mute_photo.."\n" 
   .."- `الدردشه` : "..mute_text.."\n" 
   .."- `الصور المتحركه` : "..mute_gifs.."\n" 
   .."- `الصوتيات` : "..mute_voice.."\n"
   .."- `الاغاني` : "..mute_music.."\n"  
   .."- `الفيديو` : "..mute_video.."\n"
   .."- `الشارحه` : "..lock_cmd.."\n"
   .."- `الماركدون` : "..mute_mdd.."\n"
   .."- `الملفات` : "..mute_doc.."\n" 
   .."- `مـدهہ‏‏ صـلآحيهہ‏‏ آلبوت` : "..exp_dat.." `يوم`\n" .." ¥==============¥"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
	---------------------------------------by faeder--------------------------------------------------------
  	if text:match("كرر (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "(كرر) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------by faeder------------------------------------------------------------
  	if text:match("ضع قوانين (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "(ضع قوانين) (.*)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
       send(msg.chat_id_, msg.id_, 1, '_تم وضع قوانين المجموعة 👁‍🗨 _', 1, 'md')
    end
              
	--------------------------------------by faeder---------------------------------------------------------
  	if text:match("القوانين") then
	local rules = database:get('bot:rules'..msg.chat_id_)
         send(msg.chat_id_, msg.id_, 1, rules, 1, nil)
    end
	----------------------------by faeder------------------------------------------------------------------
 if text:match("^[Dd][Ee][Vv]$")or text:match("^مطور بوت$") or text:match("^مطورين$") or text:match("^مطور البوت$") or text:match("^مطور$") or text:match("^المطور$") and msg.reply_to_message_id_ == 0 then
sendContact(msg.chat_id_, msg.id_, 0, 1, nil, (nkeko or 9647713642534), (nakeko or "فايدر faeder"), "", bot_id)
end
------------------------------by faeder---------------------------------------------------------------------
if text:match("^[Gg][Rr][Oo][Uu][Pp][Ss]$") and is_admin(msg.sender_user_id_, msg.chat_id_) or text:match("^الكروبات$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
 local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Groups :* '..gps..'', 1, 'md')
                 else
      send(msg.chat_id_, msg.id_, 1, '🔘 - عدد الكروبات هي 🚧 ┇ *'..gps..'*', 1, 'md')
end
 end
 
if  text:match("^[Mm][Ss][Gg]$") or text:match("^رسائلي$") and msg.reply_to_message_id_ == 0  then
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*Msgs : * "..user_msgs.."", 1, 'md')
    else 
  send(msg.chat_id_, msg.id_, 1, "🔘 - عدد رسائلك هي 📨 ┇ *"..user_msgs.."*", 1, 'md')
end
 end
	-------------------------------by faeder----------------------------------------------------------------
	if text:match("^ضع اسم (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(ضع اسم) (.*)$")} 
	     changetitle(msg.chat_id_, txt[2])
         send(msg.chat_id_, msg.id_, 1, '_تم تغير اسم المجموعة🥀_', 1, 'md')
    end
	--------------------------------by faeder---------------------------------------------------------------
	if text:match("^ضع صوره$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
       send(msg.chat_id_, msg.id_, 1, '_ارسل لي صوره الان 🚧_', 1, 'md')
		 database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
    end
	------------------------------------by faeder-----------------------------------------------------------
	if text:match("^شحن مده (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
		local a = {string.match(text, "^(شحن مده) (%d+)$")} 
         send(msg.chat_id_, msg.id_, 1, '_هذا  المجموعة صالحة لغاية_ *'..a[2]..'* _يوم_', 1, 'md')
		 local time = a[2] * day
         database:setex("bot:charge:"..msg.chat_id_,time,true)
		 database:set("bot:enable:"..msg.chat_id_,true)
    end
	---------------------------by faeder--------------------------------------------------------------------
	if text:match("^صلاحيه المجموعه") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local ex = database:ttl("bot:charge:"..msg.chat_id_)
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '_الصلاحية مفتوحه 🚧_', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, d.." يوم باقي على انتهاء صلاحية المجموعه 🚧 ", 1, 'md')
       end
    end
	------------------------------by faeder-----------------------------------------------------------------
	if text:match("^تغير المده (%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(تغير المده) (%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '_غير محدوده_', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, d.." يوم باقي حتى اتهاء صلاحية المجموعة", 1, 'md')
       end
    end
	-----------------------------------all by faeder------------------------------------------------------------
	 if is_sudo(msg) then
  ----------------------------------------by faeder-------------------------------------------------------
if text:match("^مغادره (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
   local txt = {string.match(text, "^(مغادره) (-%d+)$")} 
    send(msg.chat_id_, msg.id_, 1, '🔘 - المجموعه '..txt[2]..' تم الخروج منها ✔️', 1, 'md')
    send(txt[2], 0, 1, '🔘 - هذه ليست ضمن المجموعات الخاصة بي ✖️', 1, 'md')
    chat_leave(txt[2], bot_id)
  end
  -----------------------------by faeder------------------------------------------------------------------
if text:match('المده شهر (%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "(المده شهر) (%d+)")}
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	 send(msg.chat_id_, msg.id_, 1, 'تم اعطاء صلاحيه للمجموعة بنجاح👁‍🗨 '..' \n هذه المجموعة صالحة لمدة 30 يوم(شهر 1)', 1, 'md')
	   
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User"..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  ------------------------------by faeder-----------------------------------------------------------------
if text:match('المده شهرين (%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "(المده شهرين) (%d+)")}
       local timeplan1 = 5184000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, 'تم اعطاء صلاحيه للمجموعة بنجاح⚒ '..' \n هذه المجموعة صالحة لمدة 60 يوم( شهرين)', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User"..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  ------------------------------by faeder-----------------------------------------------------------------
if text:match('المده مفتوحه (%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "(المده مفتوحه) (%d+)")}
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, 'تم اعطاء الصلاحيه بنجاح 🔘'..' \n هذه المجموعة صلاحية هذه المجموعة مفتوحه الى الابد 🚀', 1, 'md')
	   send(txt[2], 0, 1, 'الصلاحية غير محدوده🔓', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User"..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  ------------------------------by faeder-----------------------------------------------------------------
if text:match('تفعيل') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^تفعيل$")} 
       database:set("bot:charge:"..msg.chat_id_,true)
	   send(msg.chat_id_, msg.id_, 1, '❅ 【📍 تم تفعيل البوت✔️ 】 ✹', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "🔘- المطور ♦️"..msg.sender_user_id_.." تم تفعيل مجموعه جديده *" , 1, 'md')
       end
	   database:set("bot:enable:"..msg.chat_id_,true)
  end
  -------------------------------by faeder----------------------------------------------------------------
  if text:match('^تعطيل') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^تعطيل$")} 
       database:del("bot:charge:"..msg.chat_id_)
	  send(msg.chat_id_, msg.id_, 1, '_❅ 【 تم تعطيل_ البوت✔️ 】 ✹', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*🔘- المطور ♦️"..msg.sender_user_id_.." تم تعطيل مجموعه جديده*" , 1, 'md')
       end
  end
   -----------------------------by faeder------------------------------------------------------------------

------------------------------by faeder-------------------------------------------------------------------
if text:match('^تنظيف (%d+)$') and is_sudo(msg) then
  local matches = {string.match(text, "^(تنظيف) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
    pm = '- <code> لا تستطيع حذف اكثر من 100 رساله 👁‍🗨</code>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])
    }, delmsg, nil)
  pm ='- <i>[ '..matches[2]..' ]</i> <code>من الرسائل تم حذفها 👁‍🗨</code>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='- <code> هناك خطا<code>'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
              end
        end
-------------------------------by faeder------------------------------------------------------------------
 if text:match("^[Dd][Ee][Ll]$")  and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^مسح$") and msg.reply_to_message_id_ ~= 0 and is_mod(msg.sender_user_id_, msg.chat_id_) then
     delete_msg(msg.chat_id_, {[0] = msg.reply_to_message_id_})
     delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
  ---------------------------------------by faeder-------------------------------------------------------
                                       -- end code --
  ---------------------------------------by faeder--------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
  -----------------------------------by faeder------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
   local msg = data
  -- vardump(msg)
  	function get_msg_contact(extra, result, success)
	local text = (result.content_.text_ or result.content_.caption_)
    --vardump(result)
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
	end
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
   if database:get('bot:links:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("كسمك") or text:match("كس امك") or text:match("كسختك") or text:match("فرخ") or text:match("انيجك") or text:match("منيوج") or text:match("تنيج") or text:match("كحبه") or text:match("اختك") or text:match("امك") or text:match("ارضع") or text:match("عير") or text:match("تنيج") or text:match("تبياته") or text:match("انيجه") or text:match("ابنالكحبه") or text:match("ابن الكحبه") or text:match("اخ الكحبه") or text:match("اخالكحبه") or text:match("عريض") or text:match("تنح") or text:match("كس") then
   if database:get('bot:faeder:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
       send(msg.chat_id_, msg.id_, 1, '> _💈 ايدي الدوده 🆔_  *('..msg.sender_user_id_..')* \n_الفاضك يمطي 🔸', 1, 'md')
 end
   end
   if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("اخدر") or text:match("احبج") or text:match("تعالي خاص") or text:match("تعاي خاص") or text:match("خاصج") or text:match("مح") or text:match("تنيج") or text:match("تحبيني") or text:match("امصج") or text:match("كمر") or text:match("احبك") or text:match("تعال خاص") or text:match("دزي خاص") or text:match("جيتج خاص") or text:match("حلق") or text:match("حبيبتي") or text:match("اوف") or text:match("شهالكمر") or text:match("ممكن خاص") or text:match("اعشقج") or text:match("احبك") or text:match("هبج")then
   if database:get('bot:faederdx:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
       send(msg.chat_id_, msg.id_, 1, '> _💈 ايدي الزاحف🆔_  *('..msg.sender_user_id_..')* \n_الزحف مقفول هنا يمطي._\nتم مسح رسالتك 🐸🗯', 1, 'md')
 end
   end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   if text:match("@") then
   if database:get('bot:tag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   	if text:match("#") then
   if database:get('bot:hashtag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   	if text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
   if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
   end
    end
	end
	if database:get('editmsg'..msg.chat_id_) == 'delmsg' then
        local id = msg.message_id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
              delete_msg(chat,msgs)
	elseif database:get('editmsg'..msg.chat_id_) == 'didam' then
	if database:get('bot:editid'..msg.message_id_) then
		local old_text = database:get('bot:editid'..msg.message_id_)
	         send(msg.chat_id_, msg.message_id_, 1, ' - `لقد قمت بالتعديل` ❌\n\n -`رسالتك السابقه ` ⬇️  : \n\n - [ '..old_text..' ]', 1, 'md')
	end
	end
    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
  --------------------------------------by faeder---------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
end
end
end
end
end
--[[
-- يلا اخمط من عمك فايدر  @pro_c9
--]]
end