--- @since 25.4.8

local M = {}

local function fail(job, s)
	ya.preview_widget(job, ui.Text.parse(s):area(job.area):wrap(ui.Wrap.YES))
end

function M:peek(job)
	if not job.file then
		return
	end

	local child, err = Command("bat")
		:arg({
			"--style",
			"numbers",
			"--color",
			"always",
			"--theme",
			"tokyonight_night",
			tostring(job.file.url),
			"--wrap=never",
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return fail(job, "bat: " .. err)
	end

	local max_lines = job.area.h
	local i, outs = 0, {}

	repeat
		local next, event = child:read_line()
		if event == 1 then
			ya.err("bat error: " .. next)
		elseif event ~= 0 then
			break
		end

		i = i + 1
		if i > job.skip then
			outs[#outs + 1] = next
		end
	until i >= job.skip + max_lines

	child:start_kill()

	if job.skip > 0 and i < job.skip + max_lines then
		ya.emit("peek", { math.max(0, i - max_lines), only_if = job.file.url, upper_bound = true })
	else
		local s = table.concat(outs, ""):gsub("\t", string.rep(" ", rt.preview.tab_size))
		ya.preview_widget(job, ui.Text.parse(s):area(job.area))
	end
end

function M:seek(job)
	require("code"):seek(job)
end

return M
