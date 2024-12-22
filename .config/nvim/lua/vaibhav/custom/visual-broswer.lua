local open_selected = function()
	local selected_prompt = vim.fn.getreg("+")
	if selected_prompt then
		if selected_prompt:find("https://") then
			local cmd = "xdg-open " .. selected_prompt
			os.execute(cmd)
		else
			local default_google_query = "https://www.google.com/search?q="
			local cmd = "xdg-open '" .. default_google_query .. selected_prompt .. "'"
			os.execute(cmd)
		end
	end
end

vim.keymap.set("v", "<leader>o", open_selected, {
	silent = true,
})
vim.keymap.set("n", "<leader>o", open_selected, {
	silent = true,
})
