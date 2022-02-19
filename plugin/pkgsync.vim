
let g:loaded_pkgsync = 1

let s:KIND_UPDATING = 0
let s:KIND_INSTALLING = 1
let s:KIND_DELETING = 2
let s:KIND_ERROR = 3
let s:KIND_NORMAL = 4

command! -bar -nargs=0 -bang PkgSync :call <SID>pkgsync((<q-bang> == '!'), get(g:, 'pkgsync_path', '~/pkgsync.json'))

function! s:pkgsync(bang, path) abort
	let m = &more
	try
		set nomore
		if filereadable(expand(a:path))
			let j = json_decode(join(readfile(expand(a:path)), ''))
			let packpath = expand(get(j, 'packpath', ''))
			if isdirectory(expand(packpath))
				let start_d = get(get(j, 'plugins', {}), 'start', {})
				let opt_d = get(get(j, 'plugins', {}), 'opt', {})
				let params = s:make_params(packpath, start_d, opt_d)
				call s:start_jobs(params)
				call s:wait_jobs(params)
				call s:helptags(params)
				if a:bang
					call s:delete_unmanaged_plugins(packpath, start_d, opt_d)
				endif
			else
				call s:echomsg(s:KIND_ERROR, printf('Could not find "%s". Please create the directory!', packpath))
			endif
		else
			call s:echomsg(s:KIND_ERROR, printf('Could not find "%s". Please create the file!', a:path))
		endif
	finally
		let &more = m
	endtry
endfunction

function! s:make_params(pack_dir, start_d, opt_d) abort
	let base_cmd = 'git -c credential.helper= '
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
						\   'cmd': printf('%s pull', base_cmd),
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
						\   'cmd': printf(
						\     '%s clone --origin origin --depth 1 https://github.com/%s.git', base_cmd, printf('%s/%s', username, plugin_name)
						\   ),
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
		call s:echomsg(s:KIND_DELETING, printf('Deleting the unmanaged directory: "%s"', a:path))
		call delete(a:path, 'rf')
	endif
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
	call s:echomsg(s:KIND_NORMAL, '[pkgsync] ' .. strftime("%c", localtime()))
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
			call s:echomsg(param['kind'], printf('%3d/%d. %s %s(%s)',
				\	n, len(a:params), kind_msg, param['name'], param['start_or_opt']))

			if has('nvim')
				for line in param['arg']['lines']
					if !empty(trim(line))
						call s:echomsg(s:KIND_NORMAL, '  ' .. line)
					endif
				endfor
			else
				if filereadable(param['arg'])
					for line in readfile(param['arg'])
						if !empty(trim(line))
							call s:echomsg(s:KIND_NORMAL, '  ' .. line)
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

function s:echomsg(kind, text) abort
	if a:kind == s:KIND_UPDATING
		echohl Title
	elseif a:kind == s:KIND_INSTALLING
		echohl Type
	elseif a:kind == s:KIND_DELETING
		echohl PreProc
	elseif a:kind == s:KIND_ERROR
		echohl Error
	else
		echohl None
	endif
	echomsg a:text
	echohl None
endfunction

