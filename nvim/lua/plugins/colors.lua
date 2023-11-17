function SetTheme(color)
	color = color or "onedark"
	vim.cmd.colorscheme(color)

end

require('onedark').setup {
    style = 'darker'
}
require('onedark').load()
return {
    'navarasu/onedark.nvim'
}


SetTheme()
