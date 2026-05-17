-- 1. 定义一个同步动作，专门用来访问 cx 并触发指令
local do_smart_enter = ya.sync(function(state)
	local h = cx.active.current.hovered

	if h and h.cha.is_dir then
		-- 如果是文件夹，执行进入
		ya.manager_emit("enter", {})
	else
		-- 如果是普通文件，执行打开
		ya.manager_emit("open", { hovered = true })
	end
end)

return {
	-- 2. entry 必须是一个标准的普通函数
	entry = function(self, args)
		-- 3. 在这里调用写好的同步动作
		do_smart_enter()
	end,
}
