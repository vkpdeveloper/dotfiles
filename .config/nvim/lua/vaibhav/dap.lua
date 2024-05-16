local dap = require("dap")

dap.adapters.php = {
	type = "executable",
	command = "node",
	args = { os.getenv("HOME") .. "/vscode-php-debug/out/phpDebug.js" },
}

dap.configurations.php = {
	{
		type = "php",
		request = "launch",
		name = "Launch built-in server and debug",
		runtimeArgs = {
			"-S",
			"localhost:8000",
			"-t",
			".",
		},
		port = 9003,
		serverActionReady = {
			action = "openExternally",
		},
	},
}
