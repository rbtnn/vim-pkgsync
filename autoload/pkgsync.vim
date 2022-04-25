
let s:CMDFORMAT_CLONE = 'git -c credential.helper= clone --no-tags --single-branch --depth 1 https://github.com/%s/%s.git'
let s:CMDFORMAT_PULL  = 'git -c credential.helper= pull'

let s:KIND_UPDATING = 0
let s:KIND_INSTALLING = 1

let s:subcmd2functions = {
	\ 'init': function('pkgsync#init'),
	\ 'list': function('pkgsync#list'),
	\ 'install': function('pkgsync#install'),
	\ 'uninstall': function('pkgsync#uninstall'),
	\ 'update': function('pkgsync#update'),
	\ 'clean': function('pkgsync#clean'),
	\ 'help': function('pkgsync#help'),
	\ }

let s:config_path = expand('~/pkgsync.json')
let s:root_dir = expand('<sfile>:h:h')

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
		call pkgsync#help(args)
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

function! pkgsync#init(args) abort
	if filereadable(s:config_path)
		call pkgsync#error('You are already initialized!')
	endif
	call s:write_config({
		\   'packpath': get(a:args, 1, '~/vim'),
		\   'plugins': {
		\     'start': {},
		\     'opt': {},
		\   },
		\ })
	call pkgsync#output('The initialization finished!')
endfunction

function! pkgsync#list(args) abort
	let j = s:read_config()
	call pkgsync#output('[packpath]')
	call pkgsync#output('  ' .. j['packpath'])
	call pkgsync#output(' ')
	call pkgsync#output('[start]')
	for user in sort(keys(j['plugins']['start']))
		for plugname in sort(j['plugins']['start'][user])
			call pkgsync#output(printf('  %s/%s', user, plugname))
		endfor
	endfor
	call pkgsync#output(' ')
	call pkgsync#output('[opt]')
	for user in sort(keys(j['plugins']['opt']))
		for plugname in sort(j['plugins']['opt'][user])
			call pkgsync#output(printf('  %s/%s', user, plugname))
		endfor
	endfor
endfunction

function! pkgsync#install(args) abort
	let j = s:read_config()
	let m = matchlist(join(a:args), '^install\s\+\(opt\s\+\)\?\([^/]\+\)/\([^/]\+\)$')
	if !empty(m)
		let start_or_opt = (m[1] =~# '^opt\s\+$') ? 'opt' : 'start'
		let user = m[2]
		let plugname = m[3]
		let d = {}
		let d[user] = [plugname]
		let params = s:make_params(j['packpath'], (start_or_opt == 'start') ? d : {}, (start_or_opt == 'opt') ? d : {})
		call s:start_jobs(params)
		call s:wait_jobs(params)
		call s:helptags(params)
		let path = globpath(j['packpath'], join(['pack', user, start_or_opt, plugname], '/'))
		if isdirectory(path)
			let j['plugins'][start_or_opt][user] = get(j['plugins'][start_or_opt], user, [])
			if -1 == index(j['plugins'][start_or_opt][user], plugname)
				let j['plugins'][start_or_opt][user] += [plugname]
			endif
			call s:write_config(j)
		endif
	else
		call pkgsync#error('Invalid arguments!')
	endif
endfunction

function! pkgsync#uninstall(args) abort
	let j = s:read_config()
	let m = matchlist(join(a:args), '^uninstall\s\+\(opt\s\+\)\?\([^/]\+\)/\([^/]\+\)$')
	if !empty(m)
		let start_or_opt = (m[1] =~# '^opt\s\+$') ? 'opt' : 'start'
		let user = m[2]
		let plugname = m[3]
		let j['plugins'][start_or_opt][user] = get(j['plugins'][start_or_opt], user, [])
		let i = index(j['plugins'][start_or_opt][user], plugname)
		if -1 != i
			call remove(j['plugins'][start_or_opt][user], i)
		endif
		call s:write_config(j)
		let path = globpath(j['packpath'], join(['pack', user, start_or_opt, plugname], '/'))
		call s:delete_carefull(j['packpath'], path)
	else
		call pkgsync#error('Invalid arguments!')
	endif
endfunction

function! pkgsync#update(args) abort
	let j = s:read_config()
	let params = s:make_params(j['packpath'], j['plugins']['start'], j['plugins']['opt'])
	call s:start_jobs(params)
	call s:wait_jobs(params)
	call s:helptags(params)
endfunction

function! pkgsync#clean(args) abort
	let j = s:read_config()
	call s:delete_unmanaged_plugins(j['packpath'], j['plugins']['start'], j['plugins']['opt'])
endfunction

function! pkgsync#help(args) abort
	let readme_path = fnamemodify(s:root_dir .. '/README.md', ':p')
	if filereadable(readme_path)
		let lines = readfile(readme_path)
		let b = v:false
		for line in lines
			if line =~ '^### '
				let b = v:true
			endif
			if b
				if line =~ '^### '
					call pkgsync#output(line[4:])
				else
					call pkgsync#output('    ' .. line)
				endif
			endif
		endfor
	else
		call pkgsync#output('[help documents]')
	endif
endfunction

function! pkgsync#comp(ArgLead, CmdLine, CursorPos) abort
	let subcmds = keys(s:subcmd2functions)
	let xs = split(a:CmdLine, '\s\+')
	let candidates = []
	let installed_plugins = []

	if filereadable(s:config_path)
		let j = json_decode(join(readfile(s:config_path), ''))
		let start_d = get(get(j, 'plugins', {}), 'start', {})
		for user in sort(keys(start_d))
			for plugname in sort(start_d[user])
				let installed_plugins += [printf('%s/%s', user, plugname)]
			endfor
		endfor
		let opt_d = get(get(j, 'plugins', {}), 'opt', {})
		for user in sort(keys(opt_d))
			for plugname in sort(opt_d[user])
				let installed_plugins += [printf('%s/%s', user, plugname)]
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



function! s:read_config() abort
	if filereadable(s:config_path)
		let j = json_decode(join(readfile(s:config_path), ''))
		if !has_key(j, 'packpath') || !has_key(j, 'plugins')
			call pkgsync#error(printf('%s is broken! Please you should remove it and try initialization again!', string(s:config_path)))
		endif
		return {
			\   'packpath': expand(j['packpath']),
			\   'plugins': {
			\     'start': get(j['plugins'], 'start', {}),
			\     'opt': get(j['plugins'], 'opt', {}),
			\   }
			\ }
	else
		call pkgsync#error('You are not initialized vim-pkgsync! Please initialize it!')
	endif
endfunction

function! s:write_config(j) abort
	call writefile([json_encode(a:j)], s:config_path)
endfunction

function! s:make_params(pack_dir, start_d, opt_d) abort
	let params = []
	for d in [a:start_d, a:opt_d]
		let start_or_opt = (d == a:start_d ? 'start' : 'opt')
		for username in keys(d)
			let pack_dir = expand(join([a:pack_dir, 'pack', username, start_or_opt], '/'))
			if !isdirectory(pack_dir)
				call mkdir(pack_dir, 'p')
			endif
			for plugin_name in d[username]
				let plugin_dir = pack_dir .. '/' .. plugin_name
				if isdirectory(plugin_dir)
					let params += [{
						\   'name': printf('%s/%s', username, plugin_name),
						\   'cmd': s:CMDFORMAT_PULL,
						\   'cwd': plugin_dir,
						\   'arg': has('nvim') ? { 'lines': [] } : tempname(),
						\   'job': v:null,
						\   'kind': s:KIND_UPDATING,
						\   'running': v:true,
						\   'start_or_opt': start_or_opt,
						\   'plugin_dir': plugin_dir,
						\ }]
				else
					let params += [{
						\   'name': printf('%s/%s', username, plugin_name),
						\   'cmd': printf(s:CMDFORMAT_CLONE, username, plugin_name),
						\   'cwd': pack_dir,
						\   'arg': has('nvim') ? { 'lines': [] } : tempname(),
						\   'job': v:null,
						\   'kind': s:KIND_INSTALLING,
						\   'running': v:true,
						\   'start_or_opt': start_or_opt,
						\   'plugin_dir': plugin_dir,
						\ }]
				endif
			endfor
		endfor
	endfor
	return params
endfunction

function! s:start_jobs(params) abort
	if has('nvim')
		for param in a:params
			let param['job'] = jobstart(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'on_stdout': function('s:system_onevent', [param['arg']]),
				\ 'on_stderr': function('s:system_onevent', [param['arg']]),
				\ })
		endfor
	else
		for param in a:params
			let param['job'] = job_start(param['cmd'], {
				\ 'cwd': param['cwd'],
				\ 'out_io': 'file',
				\ 'out_name': param['arg'],
				\ 'err_io': 'out',
				\ })
		endfor
	endif
endfunction

function! s:wait_jobs(params) abort
	let n = 0
	while n < len(a:params)
		for param in a:params
			if !param['running']
				continue
			endif

			if has('nvim')
				if -1 == jobwait([param['job']], 0)[0]
					continue
				endif
			else
				if 'run' == job_status(param['job'])
					continue
				endif
			endif

			let n += 1
			let param['running'] = v:false
			let kind_msg = (param['kind'] == s:KIND_UPDATING) ? 'Updating' : 'Installing'
			call pkgsync#output(printf('%3d/%d. %s %s(%s)',
				\	n, len(a:params), kind_msg, param['name'], param['start_or_opt']))

			if has('nvim')
				for line in param['arg']['lines']
					if !empty(trim(line))
						call pkgsync#output('  ' .. line)
					endif
				endfor
			else
				if filereadable(param['arg'])
					for line in readfile(param['arg'])
						if !empty(trim(line))
							call pkgsync#output('  ' .. line)
						endif
					endfor
					call delete(param['arg'])
				endif
			endif
		endfor
	endwhile
endfunction

function! s:helptags(params) abort
	for param in a:params
		if isdirectory(param['plugin_dir'] .. '/doc')
			execute printf('helptags %s', fnameescape(param['plugin_dir'] .. '/doc'))
		endif
	endfor
endfunction

function s:system_onevent(d, job, data, event) abort
	let a:d['lines'] += a:data
	sleep 10m
endfunction

function! s:delete_unmanaged_plugins(pack_dir, start_d, opt_d) abort
	for d in [a:start_d, a:opt_d]
		let start_or_opt = (d == a:start_d ? 'start' : 'opt')
		for x in split(globpath(join([a:pack_dir, 'pack', '*', start_or_opt], '/'), '*'), "\n")
			let exists = v:false
			for username in keys(d)
				for plugin_name in d[username]
					if x =~# '[\/]' .. username .. '[\/]' .. start_or_opt .. '[\/]' .. plugin_name .. '$'
						let exists = v:true
						break
					endif
				endfor
			endfor
			if !exists
				call s:delete_carefull(a:pack_dir, x)
			endif
		endfor
		for x in split(globpath(join([a:pack_dir, 'pack', '*'], '/'), start_or_opt), "\n")
			if !len(readdir(x))
				call s:delete_carefull(a:pack_dir, x)
			endif
		endfor
	endfor
	for x in split(globpath(join([a:pack_dir, 'pack'], '/'), '*'), "\n")
		if !len(readdir(x))
			call s:delete_carefull(a:pack_dir, x)
		endif
	endfor
endfunction

function! s:delete_carefull(pack_dir, path) abort
	if (-1 != index(split(a:path, '[\/]'), 'pack')) && (a:path[:(len(a:pack_dir) - 1)] == a:pack_dir)
		call pkgsync#output(printf('Deleting the unmanaged directory: "%s"', a:path))
		call delete(a:path, 'rf')
	endif
endfunction

