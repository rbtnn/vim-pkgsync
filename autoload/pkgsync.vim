
let s:subcmd2functions = {
	\ 'init': function('pkgsync#subcmds#init#exec'),
	\ 'list': function('pkgsync#subcmds#list#exec'),
	\ 'install': function('pkgsync#subcmds#install#exec'),
	\ 'uninstall': function('pkgsync#subcmds#uninstall#exec'),
	\ 'update': function('pkgsync#subcmds#update#exec'),
	\ 'clean': function('pkgsync#subcmds#clean#exec'),
	\ 'help': function('pkgsync#subcmds#help#exec'),
	\ }

function! pkgsync#parse_cmdline(args) abort
	let args = a:args
	if 0 < len(args)
		let i = index(keys(s:subcmd2functions), args[0])
		if -1 != i
			call call(s:subcmd2functions[args[0]], [args])
		else
			call pkgsync#error('unknown subcommand: ' .. string(args[0]))
		endif
	else
		call pkgsync#subcmds#help#exec(args)
	endif
endfunction

function! pkgsync#error(text) abort
	throw 'error: ' .. a:text
endfunction

function! pkgsync#output(text) abort
	if exists('g:pkgsync_stdout')
		put=a:text
		print
	else
		echo a:text
	endif
endfunction

function! pkgsync#comp(ArgLead, CmdLine, CursorPos) abort
	let subcmds = keys(s:subcmd2functions)
	let xs = split(a:CmdLine, '\s\+')
	let candidates = []
	let installed_plugins = []

	if filereadable(pkgsync#common#get_config_path())
		let j = json_decode(join(readfile(pkgsync#common#get_config_path()), ''))
		let start_d = get(get(j, 'plugins', {}), 'start', {})
		for user_name in sort(keys(start_d))
			for plugin_name in sort(start_d[user_name])
				let installed_plugins += [printf('%s/%s', user_name, plugin_name)]
			endfor
		endfor
		let opt_d = get(get(j, 'plugins', {}), 'opt', {})
		for user_name in sort(keys(opt_d))
			for plugin_name in sort(opt_d[user_name])
				let installed_plugins += [printf('%s/%s', user_name, plugin_name)]
			endfor
		endfor
	endif

	if (1 == len(xs))
		let candidates = subcmds
	elseif 2 == len(xs)
		if a:CmdLine =~# '\s\+$'
			if xs[1] == 'install'
				let candidates = ['opt']
			elseif xs[1] == 'uninstall'
				let candidates = ['opt']
				for x in installed_plugins
					if -1 == index(xs, x)
						let candidates += [x]
					endif
				endfor
			endif
		else
			let candidates = subcmds
		endif
	elseif (3 == len(xs)) || (4 == len(xs))
		if xs[1] == 'install'
			if a:CmdLine !~# '\s\+$'
				let candidates = ['opt']
			endif
		elseif xs[1] == 'uninstall'
			if a:CmdLine !~# '\s\+$'
				let candidates = ['opt']
			endif
			if (a:CmdLine !~# '\s\+$') || ((3 == len(xs)) && (xs[2] == 'opt'))
				for x in installed_plugins
					if -1 == index(xs, x)
						let candidates += [x]
					endif
				endfor
			endif
		endif
	endif

	return filter(candidates, { i,x -> -1 != match(x, a:ArgLead) })
endfunction

